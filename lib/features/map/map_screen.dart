import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../data/photo_store.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _controller = MapController();
  late Future<List<PhotoRecord>> _photos;
  Position? _position;
  PhotoRecord? _selected;
  bool _locating = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _photos = PhotoStore.instance.all();
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Aktifkan layanan lokasi perangkat.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izinkan akses lokasi untuk menampilkan posisi Anda.');
      }
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _position = position);
      _controller.move(LatLng(position.latitude, position.longitude), 15);
    } catch (error) {
      if (mounted) setState(() => _locationError = error.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<PhotoRecord>>(
        future: _photos,
        builder: (context, snapshot) {
          final photos = snapshot.data ?? const <PhotoRecord>[];
          return Stack(
            children: [
              FlutterMap(
                mapController: _controller,
                options: const MapOptions(
                  initialCenter: LatLng(-2.5, 118),
                  initialZoom: 4.4,
                  minZoom: 3,
                  maxZoom: 19,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.xiumark',
                  ),
                  MarkerLayer(
                    markers: [
                      for (final photo in photos)
                        Marker(
                          point: LatLng(photo.latitude, photo.longitude),
                          width: 48,
                          height: 48,
                          child: GestureDetector(
                            onTap: () => setState(() => _selected = photo),
                            child: const Icon(Icons.location_on,
                                color: Color(0xFF087E83), size: 42),
                          ),
                        ),
                      if (_position != null)
                        Marker(
                          point: LatLng(
                              _position!.latitude, _position!.longitude),
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2878E3),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 5)
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF087E83)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            snapshot.connectionState != ConnectionState.done
                                ? 'Memuat lokasi foto…'
                                : '${photos.length} lokasi foto • peta membutuhkan internet',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Posisi saya',
                          onPressed: _locating ? null : _locate,
                          icon: _locating
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_locationError != null)
                Positioned(
                  top: 76,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_locationError!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              if (_selected case final photo?)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Card(
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(photo.path),
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image_outlined)),
                      ),
                      title: Text(photo.officer.isEmpty
                          ? 'Dokumentasi lapangan'
                          : photo.officer),
                      subtitle: Text(
                          '${photo.latitude.toStringAsFixed(5)}, ${photo.longitude.toStringAsFixed(5)}\n${_formatDate(photo.takenAt)}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => setState(() => _selected = null),
                        icon: const Icon(Icons.close),
                      ),
                      onTap: () => _controller.move(
                          LatLng(photo.latitude, photo.longitude), 16),
                    ),
                  ),
                ),
            ],
          );
        },
      );

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
