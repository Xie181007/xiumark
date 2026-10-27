import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;

import '../../data/photo_store.dart';
import '../location/location_service.dart';
import '../watermark/watermark_composer.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  double _accuracyLimit = 5.0;
  ResolutionPreset _resolution = ResolutionPreset.max;
  CameraController? _camera;
  Position? _position;
  String? _error;
  bool _loading = true;
  bool _locating = false;
  bool _capturing = false;
  bool _flash = false;
  double _zoom = 1;
  double _maxZoom = 1;
  String _officer = 'Petugas';
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  final _locationService = const LocationService();

  bool get _locationValid =>
      _position != null && _position!.accuracy <= _accuracyLimit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      camera.dispose();
      _camera = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initialize() async {
    try {
      final savedOfficer = await PhotoStore.instance.officerName();
      if (savedOfficer.trim().isNotEmpty) _officer = savedOfficer.trim();
      _accuracyLimit = await PhotoStore.instance.accuracyThreshold();
      _resolution = _presetFrom(await PhotoStore.instance.cameraResolution());
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw StateError('Kamera tidak tersedia pada perangkat ini.');
      }
      _cameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_cameraIndex < 0) _cameraIndex = 0;
      await _initializeCamera();
      await _sampleLocation();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty) return;
    final old = _camera;
    _camera = null;
    await old?.dispose();
    final controller = CameraController(
      _cameras[_cameraIndex],
      _resolution,
      enableAudio: false,
    );
    _camera = controller;
    await controller.initialize();
    _maxZoom = await controller.getMaxZoomLevel();
    if (mounted) setState(() {});
  }

  ResolutionPreset _presetFrom(String value) => switch (value) {
        'low' => ResolutionPreset.low,
        'medium' => ResolutionPreset.medium,
        'high' => ResolutionPreset.high,
        'veryHigh' => ResolutionPreset.veryHigh,
        _ => ResolutionPreset.max,
      };

  Future<void> _sampleLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final position = await _locationService.getValidatedFix(
        accuracyThreshold: _accuracyLimit,
      );
      if (mounted) setState(() => _position = position);
    } on LocationValidationException catch (error) {
      if (mounted) {
        setState(() => _position = null);
        _message(error.message);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _position = null);
        _message('Gagal mendapatkan lokasi: $error');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _capture() async {
    final camera = _camera;
    final position = _position;
    if (position != null &&
        DateTime.now().difference(position.timestamp) >
            const Duration(seconds: 30)) {
      setState(() => _position = null);
      _message(
          'Sampel GPS sudah berumur lebih dari 30 detik. Ukur ulang sebelum mengambil foto.');
      await _sampleLocation();
      return;
    }
    if (camera == null ||
        !camera.value.isInitialized ||
        position == null ||
        !_locationValid ||
        _capturing) {
      return;
    }
    setState(() => _capturing = true);
    String? stagedPath;
    try {
      final shot = await camera.takePicture();
      final time = DateTime.now();
      final locationLabel = await _reverseGeocode(position);
      final directory = await PhotoStore.instance.privatePhotoDirectory();
      final fileName = 'xiumark_${time.microsecondsSinceEpoch}.png';
      final outputPath = p.join(directory, fileName);
      final savedOfficer = await PhotoStore.instance.officerName();
      final officer =
          savedOfficer.trim().isEmpty ? 'Petugas' : savedOfficer.trim();
      final watermarked = await WatermarkComposer.compose(
        sourcePath: shot.path,
        outputPath: outputPath,
        takenAt: time,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        officer: officer,
        locationLabel: locationLabel,
      );
      stagedPath = watermarked.path;
      await PhotoStore.instance.add(
        PhotoRecord(
          id: 0,
          path: watermarked.path,
          takenAt: time,
          measuredAt: position.timestamp,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          officer: officer,
        ),
      );
      try {
        await File(shot.path).delete();
      } on FileSystemException {
        // The camera plugin may already remove its temporary file.
      }
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Foto tersimpan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    watermarked,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Watermark sudah menyatu dengan foto. Akurasi GPS: ${position.accuracy.toStringAsFixed(1)} m.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      if (stagedPath != null) {
        try {
          await File(stagedPath).delete();
        } on FileSystemException {
          // Preserve the original processing error.
        }
      }
      if (mounted) _message('Foto gagal diproses: $error');
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<String?> _reverseGeocode(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 5));
      if (placemarks.isEmpty) return null;
      final place = placemarks.first;
      final parts = <String?>[
        place.street,
        place.subLocality,
        place.locality,
        place.subAdministrativeArea,
        place.administrativeArea,
      ]
          .map((value) => value?.trim())
          .whereType<String>()
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList();
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _loading = true);
    try {
      await _initializeCamera();
    } catch (error) {
      if (mounted) _message('Kamera tidak dapat dibuka: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFlash() async {
    final camera = _camera;
    if (camera == null || !camera.value.isInitialized) return;
    final next = !_flash;
    try {
      await camera.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flash = next);
    } catch (error) {
      if (mounted) _message('Flash tidak tersedia: $error');
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF101820),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (camera?.value.isInitialized == true)
                  Builder(
                    builder: (previewContext) => GestureDetector(
                      onTapDown: (details) {
                        final box =
                            previewContext.findRenderObject()! as RenderBox;
                        final point = details.localPosition;
                        camera.setFocusPoint(Offset(
                          (point.dx / box.size.width).clamp(0.0, 1.0),
                          (point.dy / box.size.height).clamp(0.0, 1.0),
                        ));
                      },
                      child: CameraPreview(camera!),
                    ),
                  )
                else
                  Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _error ?? 'Pratinjau kamera tidak tersedia',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _GpsChip(
                    position: _position,
                    valid: _locationValid,
                    locating: _locating,
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 8,
                  child: Column(
                    children: [
                      IconButton.filledTonal(
                        onPressed: _toggleFlash,
                        icon: Icon(_flash ? Icons.flash_on : Icons.flash_off),
                        tooltip: 'Flash',
                      ),
                      const SizedBox(height: 6),
                      IconButton.filledTonal(
                        onPressed: _cameras.length > 1 ? _toggleCamera : null,
                        icon: const Icon(Icons.flip_camera_android),
                        tooltip: 'Ganti kamera',
                      ),
                    ],
                  ),
                ),
                if (camera?.value.isInitialized == true)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: _WatermarkPreview(
                      position: _position,
                      officer: _officer,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (camera?.value.isInitialized == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Row(
              children: [
                const Icon(Icons.zoom_out, size: 18),
                Expanded(
                  child: Slider(
                    value: _zoom.clamp(1, _maxZoom),
                    min: 1,
                    max: _maxZoom < 1 ? 1 : _maxZoom,
                    onChanged: (value) async {
                      setState(() => _zoom = value);
                      await camera!.setZoomLevel(value);
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, size: 18),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 18),
          child: Row(
            children: [
              IconButton(
                onPressed: _locating ? null : _sampleLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                tooltip: 'Ukur GPS lagi',
              ),
              const Spacer(),
              GestureDetector(
                onTap: _locationValid && !_capturing ? _capture : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _locationValid
                        ? const Color(0xFF087E83)
                        : Colors.grey.shade400,
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _capturing
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
              const Spacer(),
              const SizedBox(width: 40),
            ],
          ),
        ),
      ],
    );
  }
}

class _GpsChip extends StatelessWidget {
  const _GpsChip({
    required this.position,
    required this.valid,
    required this.locating,
  });
  final Position? position;
  final bool valid;
  final bool locating;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xDD10212B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              valid ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: valid ? const Color(0xFF75D5A2) : const Color(0xFFFFC46B),
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              locating
                  ? 'MENGUKUR GPS…'
                  : position == null
                      ? 'GPS BELUM VALID'
                      : '${position!.accuracy.toStringAsFixed(1)} m  •  ${valid ? 'VALID' : 'TUNGGU GPS'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}

class _WatermarkPreview extends StatelessWidget {
  const _WatermarkPreview({required this.position, required this.officer});
  final Position? position;
  final String officer;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xCC001725),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/images/telkom_akses_logo.png',
              width: 76,
              height: 48,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${DateTime.now().toLocal().toString().substring(0, 19)}\n${position == null ? 'Lokasi menunggu GPS' : '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}  •  ±${position!.accuracy.toStringAsFixed(1)} m'}\nPetugas: $officer',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
}
