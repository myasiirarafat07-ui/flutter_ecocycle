import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/wishlist_api_service.dart';

/// Daftar favorit tersinkron dengan backend (tabel wishlists).
class WishlistProvider extends ChangeNotifier {
  final WishlistApiService _api = WishlistApiService();

  String _token = '';
  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList();
  int get count => _items.length;

  bool isFavorite(int productId) => _items.containsKey(productId);

  void _setAll(List<Product> products) {
    _items
      ..clear()
      ..addEntries(products.map((p) => MapEntry(p.id, p)));
    notifyListeners();
  }

  Future<void> load(String token) async {
    _token = token;
    if (token.isEmpty) {
      _items.clear();
      notifyListeners();
      return;
    }
    try {
      _setAll(await _api.getWishlist(token));
    } catch (_) {
      // biarkan apa adanya bila gagal
    }
  }

  Future<void> toggle(Product product) async {
    if (_token.isEmpty) return;
    final wasFav = _items.containsKey(product.id);

    // Optimistic update agar ikon hati responsif.
    if (wasFav) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }
    notifyListeners();

    try {
      final list = wasFav
          ? await _api.remove(_token, product.id)
          : await _api.add(_token, product.id);
      _setAll(list);
    } catch (_) {
      // Revert bila gagal.
      if (wasFav) {
        _items[product.id] = product;
      } else {
        _items.remove(product.id);
      }
      notifyListeners();
    }
  }

  Future<void> remove(int productId) async {
    if (_token.isEmpty) return;
    final removed = _items.remove(productId);
    notifyListeners();
    try {
      _setAll(await _api.remove(_token, productId));
    } catch (_) {
      if (removed != null) {
        _items[productId] = removed;
        notifyListeners();
      }
    }
  }

  void reset() {
    _token = '';
    _items.clear();
    notifyListeners();
  }
}
