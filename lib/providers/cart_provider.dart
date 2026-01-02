import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/product_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);
  bool get isEmpty => _items.isEmpty;
  int get totalItems =>
      _items.values.fold<int>(0, (sum, item) => sum + item.quantity);
  double get totalPrice =>
      _items.values.fold<double>(0, (sum, item) => sum + item.subtotal);

  void addProduct(ProductItem product, {int quantity = 1}) {
    final key = _keyForProduct(product);
    if (_items.containsKey(key)) {
      final current = _items[key]!;
      _items[key] = current.copyWith(quantity: current.quantity + quantity);
    } else {
      _items[key] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void updateQuantity(ProductItem product, int quantity) {
    final key = _keyForProduct(product);
    if (!_items.containsKey(key)) {
      return;
    }
    if (quantity <= 0) {
      _items.remove(key);
    } else {
      _items[key] = _items[key]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeProduct(ProductItem product) {
    final key = _keyForProduct(product);
    if (_items.remove(key) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  int _keyForProduct(ProductItem product) {
    return product.id ?? product.name.hashCode;
  }
}
