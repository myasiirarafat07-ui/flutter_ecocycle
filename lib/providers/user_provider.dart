import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_api_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _tokenKey = 'auth_token';
  final AuthApiService _authApi = AuthApiService();

  String _token = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  double? _latitude;
  double? _longitude;
  String _photo = '';
  String _memberSince = '';

  int _ecoPoints = 0;
  double _totalWasteKg = 0;
  int _greenTransactions = 0;
  double _co2OffsetKg = 0;

  String get token => _token;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  bool get hasLocation => _latitude != null && _longitude != null;
  String get photo => _photo;
  String get memberSince => _memberSince;

  int get ecoPoints => _ecoPoints;
  double get totalWasteKg => _totalWasteKg;
  int get greenTransactions => _greenTransactions;
  double get co2OffsetKg => _co2OffsetKg;

  bool get isLoggedIn => _token.isNotEmpty && _email.isNotEmpty;

  /// Menyalin field profil dari map user respon backend.
  void _applyUser(Map<String, dynamic> user) {
    _name = user['full_name']?.toString() ?? '';
    _email = user['email']?.toString() ?? '';
    _phone = user['phone_number']?.toString() ?? '';
    _address = user['address']?.toString() ?? '';
    _latitude = _toNullableDouble(user['latitude']);
    _longitude = _toNullableDouble(user['longitude']);
    _photo = user['profile_photo']?.toString() ?? '';
    _memberSince =
        DateTime.tryParse(
          user['created_at']?.toString() ?? '',
        )?.year.toString() ??
        DateTime.now().year.toString();
    _ecoPoints = _toInt(user['eco_points']);
    _totalWasteKg = _toDouble(user['total_waste_kg']);
    _greenTransactions = _toInt(user['green_transactions']);
    _co2OffsetKg = _toDouble(user['co2_offset_kg']);
  }

  void setAuthenticatedUser({
    required String token,
    required Map<String, dynamic> user,
  }) {
    _token = token;
    _applyUser(user);
    _saveToken(token);
    notifyListeners();
  }

  /// Coba pulihkan sesi dari token tersimpan saat aplikasi dibuka.
  /// Mengembalikan true bila token valid dan user berhasil dimuat.
  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_tokenKey) ?? '';
    if (saved.isEmpty) return false;
    try {
      final user = await _authApi.me(saved);
      _token = saved;
      _applyUser(user);
      notifyListeners();
      return true;
    } catch (_) {
      // Token kedaluwarsa/tidak valid → bersihkan.
      await prefs.remove(_tokenKey);
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Dipanggil setelah update profil berhasil (token tetap sama).
  void applyUpdatedUser(Map<String, dynamic> user) {
    _applyUser(user);
    notifyListeners();
  }

  void updatePersonalInfo({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _address = address;
    notifyListeners();
  }

  /// Ganti foto profil ke server lalu sinkron state lokal.
  /// Kirim `null`/kosong untuk menghapus foto.
  Future<void> changePhoto(String? base64Photo) async {
    final updated = await _authApi.updatePhoto(
      token: _token,
      base64Photo: base64Photo,
    );
    applyUpdatedUser(updated);
  }

  void setEcoPoints(int points) {
    _ecoPoints = points;
    notifyListeners();
  }

  /// Simpan lokasi penjual (koordinat GPS) ke server lalu sinkron state lokal.
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final updated = await _authApi.updateProfile(
      token: _token,
      fullName: _name,
      email: _email,
      phoneNumber: _phone,
      address: _address,
      latitude: latitude,
      longitude: longitude,
    );
    applyUpdatedUser(updated);
  }

  void logout() {
    _token = '';
    _name = '';
    _email = '';
    _phone = '';
    _address = '';
    _latitude = null;
    _longitude = null;
    _photo = '';
    _memberSince = '';
    _ecoPoints = 0;
    _totalWasteKg = 0;
    _greenTransactions = 0;
    _co2OffsetKg = 0;
    _clearToken();
    notifyListeners();
  }

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double? _toNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
