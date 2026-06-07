import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductApiException implements Exception {
  final String message;
  const ProductApiException(this.message);
  @override
  String toString() => message;
}

class ProductApiService {
  // Samakan dengan AuthApiService:
  // - Android Emulator: http://10.0.2.2:3000
  // - Web/Windows: http://localhost:3000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Never _fail(http.Response response) {
    String message = 'Request gagal';
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      message = data['message']?.toString() ?? message;
    } catch (_) {}
    throw ProductApiException(message);
  }

  Future<List<Product>> fetchProducts({
    String? category,
    String? search,
    String? sort,
    String? token,
  }) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'Semua') {
      query['category'] = category;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;

    final uri = Uri.parse(
      '$baseUrl/api/products',
    ).replace(queryParameters: query.isEmpty ? null : query);

    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode != 200) _fail(response);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>? ?? []);
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> fetchProduct(int id, {String? token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  Future<List<Product>> fetchMyProducts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/mine'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>? ?? []);
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> createProduct({
    required String token,
    required String name,
    required String category,
    required String description,
    required int price,
    required int stock,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode != 201) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  Future<Product> updateProduct({
    required String token,
    required int id,
    required String name,
    required String category,
    required String description,
    required int price,
    required int stock,
    required String imageUrl,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
      }),
    );
    if (response.statusCode != 200) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: _headers(token),
    );
    if (response.statusCode != 200) _fail(response);
  }

  Future<List<Review>> fetchReviews(int productId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/products/$productId/reviews'),
      headers: _headers(),
    );
    if (response.statusCode != 200) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (data['data'] as List<dynamic>? ?? []);
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Review> createReview({
    required String token,
    required int productId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/$productId/reviews'),
      headers: _headers(token),
      body: jsonEncode({'rating': rating, 'comment': comment}),
    );
    if (response.statusCode != 201) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(data['review'] as Map<String, dynamic>);
  }
}
