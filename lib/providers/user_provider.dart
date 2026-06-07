import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _token = '';
  String _name = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _memberSince = '';
  String _userType = '';

  String get token => _token;
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get memberSince => _memberSince;
  String get userType => _userType;

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
    _userType = '';
    notifyListeners();
  }
}
