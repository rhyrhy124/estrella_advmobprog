import 'package:flutter/material.dart';

import '../models/product.dart';

// This provider is used to manage the products inside the cart.
class CartProvider
    extends ChangeNotifier {
  final List<Product> _items = [];

  // This returns the products currently inside the cart.
  List<Product> get items =>
      List.unmodifiable(_items);

  // This returns the number of products in the cart.
  int get itemCount =>
      _items.length;

  // This calculates the total price of all products in the cart.
  double get total {
    return _items.fold(
      0,
      (sum, product) =>
          sum + product.price,
    );
  }

  // This function adds a product to the cart.
  void addToCart(
    Product product,
  ) {
    _items.add(product);
    notifyListeners();
  }

  // This function removes a product from the cart.
  void removeFromCart(
    Product product,
  ) {
    _items.remove(product);
    notifyListeners();
  }

  // This checks if a product is already in the cart.
  bool contains(
    Product product,
  ) {
    return _items.contains(product);
  }

  // This removes all products from the cart.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}