import 'package:geolocator/geolocator.dart';

class LocationService {
  const LocationService();

  static const _sampleCount = 3;
  static const _sampleInterval = Duration(seconds: 2);
  static const _sampleTimeout = Duration(seconds: 20);

  Future<Position> getValidatedFix({required double accuracyThreshold}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationValidationException(
        'Aktifkan layanan lokasi/GPS untuk mengambil foto valid.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationValidationException(
        'Izin lokasi diperlukan agar koordinat dapat divalidasi.',
      );
    }

    final samples = <Position>[];
    for (var index = 0; index < _sampleCount; index++) {
      samples.add(await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: _sampleTimeout,
        ),
      ));
      if (index < _sampleCount - 1) {
        await Future<void>.delayed(_sampleInterval);
      }
    }

    samples.sort((first, second) => first.accuracy.compareTo(second.accuracy));
    final best = samples.first;
    if (best.accuracy > accuracyThreshold) {
      throw LocationValidationException(
        'Akurasi GPS ${best.accuracy.toStringAsFixed(1)} m; target maksimal '
        '${accuracyThreshold.toStringAsFixed(1)} m. Tunggu sinyal lebih baik.',
      );
    }

    final spread = samples
        .map((sample) => Geolocator.distanceBetween(
              best.latitude,
              best.longitude,
              sample.latitude,
              sample.longitude,
            ))
        .reduce((first, second) => first > second ? first : second);
    if (spread > accuracyThreshold * 2) {
      throw LocationValidationException(
        'Sampel GPS belum stabil (pergeseran ${spread.toStringAsFixed(1)} m). Coba lagi.',
      );
    }

    return best;
  }
}

class LocationValidationException implements Exception {
  const LocationValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
