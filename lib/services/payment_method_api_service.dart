import 'dart:convert';

import 'package:http/http.dart' as http;

class PaymentMethodApiException implements Exception {
  final String message;
  const PaymentMethodApiException(this.message);
  @override
  String toString() => message;
}

class PaymentMethod {
  final int id;
  final String methodType; // KARTU_KREDIT | KARTU_DEBIT | EWALLET
  final String label;
  final String detail;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.methodType,
    required this.label,
    required this.detail,
    required this.isDefault,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: (json['payment_method_id'] as num).toInt(),
      methodType: json['method_type']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      isDefault: json['is_default'] == true || json['is_default'] == 1,
    );
  }
}

class PaymentMethodApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Never _fail(http.Response response) {
    String message = 'Request gagal';
    try {
      message =
          (jsonDecode(response.body) as Map)['message']?.toString() ?? message;
    } catch (_) {}
    throw PaymentMethodApiException(message);
  }

  List<PaymentMethod> _parse(http.Response response, int okStatus) {
    if (response.statusCode != okStatus) _fail(response);
    final data = (jsonDecode(response.body) as Map)['data'] as List<dynamic>?;
    return (data ?? [])
        .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PaymentMethod>> getMethods(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/payment-methods'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<List<PaymentMethod>> add(
    String token, {
    required String methodType,
    required String label,
    required String detail,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/payment-methods'),
      headers: _headers(token),
      body: jsonEncode({
        'method_type': methodType,
        'label': label,
        'detail': detail,
      }),
    );
    return _parse(r, 201);
  }

  Future<List<PaymentMethod>> remove(String token, int id) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/api/payment-methods/$id'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<List<PaymentMethod>> clearAll(String token) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/api/payment-methods'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<List<PaymentMethod>> setDefault(String token, int id) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/payment-methods/$id/default'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }
}
