import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/order_model.dart';

class OrderApiException implements Exception {
  final String message;
  const OrderApiException(this.message);
  @override
  String toString() => message;
}

/// Hasil satu halaman daftar pesanan/penjualan (untuk infinite scroll).
class OrderPage {
  final List<Order> orders;
  final bool hasMore;
  const OrderPage({required this.orders, required this.hasMore});
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
    String paymentMethod = 'COD',
    double? buyerLat,
    double? buyerLng,
    List<Map<String, dynamic>>? items,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: _headers(token),
      body: jsonEncode({
        'shipping_method': shippingMethod,
        'payment_method': paymentMethod,
        if (buyerLat != null && buyerLng != null) ...{
          'buyer_lat': buyerLat,
          'buyer_lng': buyerLng,
        },
        if (items != null) 'items': items,
      }),
    );
    if (r.statusCode != 201) _fail(r);
    return Order.fromJson(
      (jsonDecode(r.body) as Map)['order'] as Map<String, dynamic>,
    );
  }

  Future<OrderPage> myOrders(String token, {int page = 1, int limit = 12}) =>
      _list('$baseUrl/api/orders', token, page, limit);

  Future<OrderPage> mySales(String token, {int page = 1, int limit = 12}) =>
      _list('$baseUrl/api/orders/sales', token, page, limit);

  Future<OrderPage> _list(String url, String token, int page, int limit) async {
    final uri = Uri.parse(
      url,
    ).replace(queryParameters: {'page': '$page', 'limit': '$limit'});
    final r = await http.get(uri, headers: _headers(token));
    if (r.statusCode != 200) _fail(r);
    final body = jsonDecode(r.body) as Map;
    final data = body['data'] as List<dynamic>?;
    final orders = (data ?? [])
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
    return OrderPage(
      orders: orders,
      hasMore: body['has_more'] == true || body['has_more'] == 1,
    );
  }

  Future<Order> getOrder(String token, int orderId) async {
    final r = await http.get(
      Uri.parse('$baseUrl/api/orders/$orderId'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) _fail(r);
    return Order.fromJson(
      (jsonDecode(r.body) as Map)['order'] as Map<String, dynamic>,
    );
  }

  /// Penjual mengirim/menyerahkan barang: DIPROSES -> DIKIRIM.
  Future<void> shipOrder(String token, int orderId) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/orders/$orderId/ship'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) _fail(r);
  }

  /// Penjual mengonfirmasi sudah menerima uang (COD): payment PENDING -> PAID.
  Future<void> confirmPayment(String token, int orderId) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/orders/$orderId/confirm-payment'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) _fail(r);
  }

  /// Pembeli mengonfirmasi pesanan sudah diterima: DIKIRIM -> SELESAI.
  Future<void> completeOrder(String token, int orderId) async {
    final r = await http.put(
      Uri.parse('$baseUrl/api/orders/$orderId/complete'),
      headers: _headers(token),
    );
    if (r.statusCode != 200) _fail(r);
  }
}
