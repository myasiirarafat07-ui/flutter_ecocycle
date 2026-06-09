import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
    int? minPrice,
    int? maxPrice,
    double? minRating,
  }) async {
    final query = <String, String>{};
    if (category != null && category.isNotEmpty && category != 'Semua') {
      query['category'] = category;
    }
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (sort != null && sort.isNotEmpty) query['sort'] = sort;
    if (minPrice != null && minPrice > 0) {
      query['min_price'] = minPrice.toString();
    }
    if (maxPrice != null && maxPrice > 0) {
      query['max_price'] = maxPrice.toString();
    }
    if (minRating != null && minRating > 0) {
      query['min_rating'] = minRating.toString();
    }

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

  /// Unggah file gambar (multipart) → daftar URL relatif tersaji server
  /// (mis. `/uploads/products/x.jpg`). Dipakai sebelum create/update produk.
  Future<List<String>> uploadImages({
    required String token,
    required List<XFile> files,
  }) async {
    if (files.isEmpty) return const [];
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/api/products/images'));
    request.headers['Authorization'] = 'Bearer $token';
    for (final f in files) {
      final bytes = await f.readAsBytes();
      request.files
          .add(http.MultipartFile.fromBytes('images', bytes, filename: f.name));
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 201) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['urls'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
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
    List<String> images = const [],
    double wasteKg = 0,
    double weightKg = 0,
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
        'images': images,
        'waste_kg': wasteKg,
        'weight_kg': weightKg,
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
    List<String> images = const [],
    double wasteKg = 0,
    double weightKg = 0,
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
        'images': images,
        'waste_kg': wasteKg,
        'weight_kg': weightKg,
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
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products/$productId/reviews'),
      headers: _headers(token),
      body: jsonEncode({
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      }),
    );
    if (response.statusCode != 201) _fail(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(data['review'] as Map<String, dynamic>);
  }
}
