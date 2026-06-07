import 'package:flutter/material.dart';

import '../models/product_model.dart';

/// Daftar favorit in-memory (reset saat app ditutup).
class WishlistProvider extends ChangeNotifier {
  final Map<int, Product> _items = {};

  List<Product> get items => _items.values.toList();
  int get count => _items.length;

  bool isFavorite(int productId) => _items.containsKey(productId);

  void toggle(Product product) {
    if (_items.containsKey(product.id)) {
      _items.remove(product.id);
    } else {
      _items[product.id] = product;
    }
    notifyListeners();
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
  }
}
