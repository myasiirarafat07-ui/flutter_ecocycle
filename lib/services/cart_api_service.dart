import 'dart:convert';

import 'package:http/http.dart' as http;

import '../providers/cart_provider.dart';

class CartApiException implements Exception {
  final String message;
  const CartApiException(this.message);
  @override
  String toString() => message;
}

class CartApiService {
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
    throw CartApiException(message);
  }

  List<CartItem> _parse(http.Response response, int okStatus) {
    if (response.statusCode != okStatus) _fail(response);
    final data = (jsonDecode(response.body) as Map)['data'] as List<dynamic>?;
    return (data ?? [])
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CartItem>> getCart(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/cart'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<List<CartItem>> add(
    String token,
    int productId, [
    int quantity = 1,
  ]) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/cart'),
      headers: _headers(token),
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    return _parse(r, 201);
  }

  Future<List<CartItem>> update(
    String token,
    int productId,
    int quantity,
  ) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/cart/$productId'),
      headers: _headers(token),
      body: jsonEncode({'quantity': quantity}),
    );
    return _parse(r, 200);
  }

  Future<List<CartItem>> remove(String token, int productId) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/api/cart/$productId'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<void> clear(String token) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/api/cart'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) _fail(r);
  }
}
