import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _token = '';
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

  String get token => _token;
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

  bool get isLoggedIn => _token.isNotEmpty && _email.isNotEmpty;

  void setAuthenticatedUser({
    required String token,
    required Map<String, dynamic> user,
  }) {
    _token = token;
    _name = user['full_name']?.toString() ?? '';
    _email = user['email']?.toString() ?? '';
    _phone = user['phone_number']?.toString() ?? '';
    _address = user['address']?.toString() ?? '';
    _memberSince =
        DateTime.tryParse(
          user['created_at']?.toString() ?? '',
        )?.year.toString() ??
        DateTime.now().year.toString();
    _userType = user['user_type']?.toString() ?? '';
    _isPremium = user['is_premium'] == true || user['is_premium'] == 1;
    _totalWasteKg =
        double.tryParse(user['total_waste_kg']?.toString() ?? '0') ?? 0;
    _weeklyChangePercent = 0;
    _treesPlanted = int.tryParse(user['trees_planted']?.toString() ?? '0') ?? 0;
    _co2OffsetKg =
        double.tryParse(user['co2_offset_kg']?.toString() ?? '0') ?? 0;
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

  void logout() {
    _token = '';
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
