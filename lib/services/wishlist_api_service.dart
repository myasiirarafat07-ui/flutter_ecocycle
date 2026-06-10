import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class WishlistApiException implements Exception {
  final String message;
  const WishlistApiException(this.message);
  @override
  String toString() => message;
}

class WishlistApiService {
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
    throw WishlistApiException(message);
  }

  List<Product> _parse(http.Response response, int okStatus) {
    if (response.statusCode != okStatus) _fail(response);
    final data = (jsonDecode(response.body) as Map)['data'] as List<dynamic>?;
    return (data ?? [])
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> getWishlist(String token) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/wishlist'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }

  Future<List<Product>> add(String token, int productId) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/wishlist'),
      headers: _headers(token),
      body: jsonEncode({'product_id': productId}),
    );
    return _parse(r, 201);
  }

  Future<List<Product>> remove(String token, int productId) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/api/wishlist/$productId'),
      headers: _headers(token),
    );
    return _parse(r, 200);
  }
}
