import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiException implements Exception {
  final String message;

  const AuthApiException(this.message);

  @override
  String toString() => message;
}

class AuthResult {
  final String token;
  final Map<String, dynamic> user;

  const AuthResult({required this.token, required this.user});
}

class AuthApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String userType,
  }) async {
    return _postAuth('/api/auth/register', {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'user_type': userType,
    });
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    return _postAuth('/api/auth/login', {'email': email, 'password': password});
  }

  Future<AuthResult> _postAuth(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(data['message']?.toString() ?? 'Request gagal');
    }

    return AuthResult(
      token: data['token'].toString(),
      user: data['user'] as Map<String, dynamic>,
    );
  }
}
