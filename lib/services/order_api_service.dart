import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order_model.dart';

class OrderApiException implements Exception {
  final String message;
  const OrderApiException(this.message);
  @override
  String toString() => message;
}

class OrderApiService {
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
    throw OrderApiException(message);
  }

  /// items null → pakai keranjang server; items diisi → buy-now.
  Future<Order> createOrder({
    required String token,
    required String shippingMethod,
    String paymentMethod = 'EcoWallet',
    List<Map<String, dynamic>>? items,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers(token),
      body: jsonEncode({
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        if (items != null) 'items': items,
      }),
    );
    if (r.statusCode != 201) _fail(r);
    return Order.fromJson(
        (jsonDecode(r.body) as Map)['order'] as Map<String, dynamic>);
  }

  Future<List<Order>> myOrders(String token) =>
      _list('$baseUrl/api/orders', token);

  Future<List<Order>> mySales(String token) =>
      _list('$baseUrl/api/orders/sales', token);

  Future<List<Order>> _list(String url, String token) async {
    final r = await http.get(Uri.parse(url), headers: _headers(token));
    if (r.statusCode != 200) _fail(r);
    final data = (jsonDecode(r.body) as Map)['data'] as List<dynamic>?;
    return (data ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getOrder(String token, int orderId) async {
    final r = await http.get(Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: _headers(token));
    if (r.statusCode != 200) _fail(r);
    return Order.fromJson(
        (jsonDecode(r.body) as Map)['order'] as Map<String, dynamic>);
  }
}
