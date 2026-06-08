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
  // Ganti URL ini bergantung pada cara Anda menjalankan aplikasinya:
  // - Android Emulator: 'http://10.0.2.2:3000'
  // - Web (Chrome) / Windows App: 'http://localhost:3000'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    return _postAuth('/api/auth/register', {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
    });
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    return _postAuth('/api/auth/login', {'email': email, 'password': password});
  }

  /// Langkah 1 lupa kata sandi: verifikasi email + nomor HP, server kirim OTP ke email.
  /// Mengembalikan kode OTP bila server berjalan dalam mode dev (SMTP belum
  /// dikonfigurasi); `null` bila OTP dikirim lewat email asli.
  Future<String?> forgotPassword({
    required String email,
    required String phoneNumber,
  }) async {
    final data = await _post('/api/auth/forgot-password', {
      'email': email,
      'phone_number': phoneNumber,
    });
    return data['dev_otp']?.toString();
  }

  /// Langkah 2 lupa kata sandi: verifikasi OTP, kembalikan resetToken.
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final data = await _post('/api/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
    return data['resetToken'].toString();
  }

  /// Langkah 3 lupa kata sandi: set kata sandi baru memakai resetToken.
  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    await _post('/api/auth/reset-password', {
      'resetToken': resetToken,
      'new_password': newPassword,
    });
  }

  /// Mengambil profil user dari token tersimpan (untuk restore sesi login).
  Future<Map<String, dynamic>> me(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(data['message']?.toString() ?? 'Sesi tidak valid');
    }

    return data['user'] as Map<String, dynamic>;
  }

  /// Memperbarui profil pengguna yang sedang login. Mengembalikan map user terbaru.
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/me');
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(data['message']?.toString() ?? 'Request gagal');
    }

    return data['user'] as Map<String, dynamic>;
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

  /// POST generik yang mengembalikan body JSON mentah, melempar [AuthApiException]
  /// bila status non-2xx.
  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
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

    return data;
  }
}
