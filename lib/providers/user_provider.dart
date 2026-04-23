import 'package:flutter/material.dart';

// ============================================================
// USER PROVIDER — state management sederhana tanpa library
// Menyimpan data user yang aktif login dan bisa diubah
// dari mana saja (login, register, personal info screen)
// ============================================================
class UserProvider extends ChangeNotifier {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _memberSince = '';
  String _userType = '';
  bool _isPremium = false;
  double _totalWasteKg = 0;
  double _weeklyChangePercent = 0;
  int _treesPlanted = 0;
  double _co2OffsetKg = 0;

  // ── Getters ──────────────────────────────────────────────
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get memberSince => _memberSince;
  String get userType => _userType;
  bool get isPremium => _isPremium;
  double get totalWasteKg => _totalWasteKg;
  double get weeklyChangePercent => _weeklyChangePercent;
  int get treesPlanted => _treesPlanted;
  double get co2OffsetKg => _co2OffsetKg;

  // ── Dipanggil saat login berhasil ────────────────────────
  void loginAs({
    required String name,
    required String email,
    String phone = '',
    String address = '',
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _address = address;
    _memberSince = DateTime.now().year.toString();
    _isPremium = false;
    _totalWasteKg = 0;
    _weeklyChangePercent = 0;
    _treesPlanted = 0;
    _co2OffsetKg = 0;
    notifyListeners();
  }

  // ── Dipanggil saat register berhasil ─────────────────────
  void registerAs({
    required String name,
    required String email,
    String phone = '',
    String userType = '',
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _address = '';
    _memberSince = DateTime.now().year.toString();
    _isPremium = false;
    _userType = userType;
    _totalWasteKg = 0;
    _weeklyChangePercent = 0;
    _treesPlanted = 0;
    _co2OffsetKg = 0;
    notifyListeners();
  }

  // ── Dipanggil dari PersonalInfoScreen saat Save Changes ──
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

  // ── Reset saat logout ────────────────────────────────────
  void logout() {
    _name = '';
    _email = '';
    _phone = '';
    _address = '';
    _memberSince = '';
    _isPremium = false;
    _userType = '';
    _totalWasteKg = 0;
    _weeklyChangePercent = 0;
    _treesPlanted = 0;
    _co2OffsetKg = 0;
    notifyListeners();
  }
}