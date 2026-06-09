import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
  @override
  String toString() => message;
}

/// Helper pengambilan lokasi GPS — menangani izin & layanan lokasi mati.
class LocationService {
  /// Ambil posisi GPS saat ini. Melempar [LocationException] dengan pesan
  /// ramah pengguna bila izin ditolak atau layanan lokasi nonaktif.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Layanan lokasi nonaktif. Aktifkan GPS perangkatmu.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Izin lokasi ditolak.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Izin lokasi diblokir permanen. Aktifkan lewat pengaturan aplikasi.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}
