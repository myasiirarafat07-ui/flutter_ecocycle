import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/cart_api_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final q = json['quantity'];
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: q is num ? q.toInt() : int.tryParse(q?.toString() ?? '') ?? 1,
    );
  }
}

/// Keranjang tersinkron dengan backend (tabel carts/cart_items).
class CartProvider extends ChangeNotifier {
  final CartApiService _api = CartApiService();

  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => _items;
  bool get loading => _loading;
  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);
  bool get isEmpty => _items.isEmpty;

  void _set(List<CartItem> items) {
    _items = items;
    notifyListeners();
  }

  Future<void> load(String token) async {
    if (token.isEmpty) {
      _set([]);
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _items = await _api.getCart(token);
    } catch (_) {
      // biarkan keranjang apa adanya bila gagal
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(String token, Product product, {int quantity = 1}) async {
    _set(await _api.add(token, product.id, quantity));
  }

  Future<void> increment(String token, int productId) async {
    final item = _items.where((e) => e.product.id == productId).firstOrNull;
    final qty = (item?.quantity ?? 0) + 1;
    _set(await _api.update(token, productId, qty));
  }

  Future<void> decrement(String token, int productId) async {
    final item = _items.where((e) => e.product.id == productId).firstOrNull;
    final qty = (item?.quantity ?? 1) - 1; // ≤0 → server hapus item
    _set(await _api.update(token, productId, qty));
  }

  Future<void> remove(String token, int productId) async {
    _set(await _api.remove(token, productId));
  }

  /// Dipanggil setelah checkout (server sudah mengosongkan keranjang).
  void reset() {
    _set([]);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
