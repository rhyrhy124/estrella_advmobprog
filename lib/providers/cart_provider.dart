import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  Cart? _cart;
  int _userId = 0;
  String? _firebaseUid;

  bool _isAdding = false;

  int _generation = 0;
  int _revision = 0;

  String? error;

  int get userId => _userId;
  Cart? get cart => _cart;

  List<CartProduct> get items =>
      _cart?.products ?? [];

  int get itemCount =>
      _cart?.totalQuantity ?? 0;

  double get total =>
      _cart?.total ?? 0.0;

  bool get isAdding => _isAdding;

  Future<void> setUser(int userId) async {
    if (userId <= 0) {
      throw StateError('Invalid DummyJSON user ID.');
    }

    resetSession();

    _userId = userId;

    await loadCart();
  }

  void setFirebaseUser(String uid) {
    if (uid.isEmpty) {
      throw StateError('Missing Firebase UID.');
    }

    resetSession();

    _firebaseUid = uid;

    // Firebase uses a local cart for this lab.
    _updateCart([]);

    notifyListeners();
  }

  void resetSession() {
    _generation++;
    _revision++;

    _userId = 0;
    _firebaseUid = null;
    _cart = null;
    _isAdding = false;
    error = null;

    notifyListeners();
  }

  Future<void> loadCart() async {
    if (_firebaseUid != null || _userId <= 0) {
      return;
    }

    final generation = _generation;
    final revision = _revision;

    try {
      final result =
          await _cartService.getCartByUserId(_userId);

      if (generation != _generation ||
          revision != _revision) {
        return;
      }

      _cart = result;
      error = null;
    } catch (_) {
      if (generation != _generation ||
          revision != _revision) {
        return;
      }

      _updateCart([]);

      error =
          'Unable to load the API cart. You can still add items.';
    }

    if (generation == _generation) {
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product) async {
    if (_isAdding) return;

    if (_firebaseUid == null && _userId <= 0) {
      throw StateError('Please sign in first.');
    }

    final generation = _generation;

    _revision++;
    _isAdding = true;

    notifyListeners();

    try {
      if (_firebaseUid != null) {
        // Local Firebase cart uses the displayed product price.
        const discount = 0.0;

        final item = CartProduct(
          id: product.id,
          title: product.title,
          price: product.price,
          quantity: 1,
          total: product.price,
          discountPercentage: discount,
          discountedTotal: product.price,
          thumbnail: product.thumbnail,
        );

        _merge([item]);
      } else {
        final result = await _cartService.addToCart(
          userId: _userId,
          productId: product.id,
          quantity: 1,
        );

        if (generation != _generation) return;

        _merge(result.products);
      }
    } finally {
      if (generation == _generation) {
        _isAdding = false;
        notifyListeners();
      }
    }
  }

  CartProduct _quantity(
    CartProduct product,
    int quantity,
  ) {
    return CartProduct(
      id: product.id,
      title: product.title,
      price: product.price,
      quantity: quantity,
      total: product.price * quantity,
      discountPercentage: product.discountPercentage,
      discountedTotal: product.price *
          quantity *
          (1 - product.discountPercentage / 100),
      thumbnail: product.thumbnail,
    );
  }

  void _merge(List<CartProduct> incoming) {
    final products =
        List<CartProduct>.from(items);

    for (final item in incoming) {
      final index = products.indexWhere(
        (product) => product.id == item.id,
      );

      if (index < 0) {
        products.add(item);
      } else {
        products[index] = _quantity(
          products[index],
          products[index].quantity + item.quantity,
        );
      }
    }

    _updateCart(products);
  }

  void increaseQuantity(int productId) {
    _change(productId, 1);
  }

  void decreaseQuantity(int productId) {
    _change(productId, -1);
  }

  void _change(int id, int delta) {
    if (_isAdding) return;

    final products =
        List<CartProduct>.from(items);

    final index = products.indexWhere(
      (product) => product.id == id,
    );

    if (index < 0) return;

    _revision++;

    final quantity =
        products[index].quantity + delta;

    if (quantity <= 0) {
      products.removeAt(index);
    } else {
      products[index] = _quantity(
        products[index],
        quantity,
      );
    }

    _updateCart(products);

    notifyListeners();
  }

  void _updateCart(
    List<CartProduct> products,
  ) {
    _cart = Cart(
      id: _cart?.id ?? 0,
      products: products,
      total: products.fold<double>(
        0,
        (sum, product) => sum + product.total,
      ),
      discountedTotal: products.fold<double>(
        0,
        (sum, product) =>
            sum + product.discountedTotal,
      ),
      userId: _userId,
      totalProducts: products.length,
      totalQuantity: products.fold<int>(
        0,
        (sum, product) => sum + product.quantity,
      ),
    );
  }

  void clearCart() {
    _generation++;
    _revision++;
    _isAdding = false;

    _updateCart([]);

    notifyListeners();
  }
}