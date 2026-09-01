import 'package:flutter/material.dart';

import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  Cart? _cart;

  // Current selected DummyJSON user.
  int _userId = 1;

  int get userId => _userId;

  Cart? get cart => _cart;

  List<CartProduct> get items =>
      _cart?.products ?? [];

  int get itemCount =>
      _cart?.totalQuantity ?? 0;

  double get total =>
      _cart?.total ?? 0.0;

  bool _isAdding = false;

  bool get isAdding => _isAdding;

  // Set the currently selected user.
  void setUser(int userId) {
    _userId = userId;

    // Clear the old user's cart from the app.
    _cart = null;

    notifyListeners();

    // Automatically load the new user's existing
    // DummyJSON cart so each user sees their own
    // API-generated items.
    loadCart();
  }

  // Load the cart of the selected user.
  Future<void> loadCart() async {
    try {
      _cart =
          await _cartService.getCartByUserId(
        _userId,
      );
    } catch (e) {
      _cart = Cart(
        id: 0,
        products: [],
        total: 0.0,
        discountedTotal: 0.0,
        userId: _userId,
        totalProducts: 0,
        totalQuantity: 0,
      );
    }

    notifyListeners();
  }

  // Add a product using the selected user's ID.
  Future<void> addToCart(
    Product product,
  ) async {
    if (_isAdding) return;

    _isAdding = true;
    notifyListeners();

    try {
      // IMPORTANT:
      // This still uses:
      // POST https://dummyjson.com/carts/add
      // The API returns the updated cart object which we
      // use as the new cart state so the Cart page shows
      // the added product.
      final apiCart =
          await _cartService.addToCart(
        userId: _userId,
        productId: product.id,
        quantity: 1,
      );

      _mergeApiCartIntoLocal(apiCart);
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  // Merge the cart returned by the DummyJSON API into
  // the current local cart so the UI reflects the
  // product added via the API.
  void _mergeApiCartIntoLocal(
    Cart apiCart,
  ) {
    final existing =
        _cart?.products ?? [];

    final merged =
        List<CartProduct>.from(existing);

    for (final apiItem in apiCart.products) {
      final index =
          merged.indexWhere(
        (item) => item.id == apiItem.id,
      );

      if (index >= 0) {
        final old = merged[index];

        merged[index] = CartProduct(
          id: old.id,
          title: old.title,
          price: old.price,
          quantity: old.quantity + apiItem.quantity,
          total: old.price *
              (old.quantity + apiItem.quantity),
          discountPercentage:
              old.discountPercentage,
          discountedTotal: old.price *
              (old.quantity + apiItem.quantity) *
              (1 -
                  old.discountPercentage /
                      100),
          thumbnail: old.thumbnail,
        );
      } else {
        merged.add(apiItem);
      }
    }

    _updateCart(merged);
  }

  // Increase a cart item's quantity by 1.
  void increaseQuantity(
    int productId,
  ) {
    if (_cart == null) return;

    final products =
        List<CartProduct>.from(
      _cart!.products,
    );

    final index =
        products.indexWhere(
      (item) => item.id == productId,
    );

    if (index < 0) return;

    final old =
        products[index];

    final newQuantity =
        old.quantity + 1;

    products[index] = CartProduct(
      id: old.id,
      title: old.title,
      price: old.price,
      quantity: newQuantity,
      total: old.price * newQuantity,
      discountPercentage:
          old.discountPercentage,
      discountedTotal: old.price *
          newQuantity *
          (1 -
              old.discountPercentage /
                  100),
      thumbnail: old.thumbnail,
    );

    _updateCart(products);
  }

  // Decrease a cart item's quantity by 1.
  // Removes the item if quantity reaches 0.
  void decreaseQuantity(
    int productId,
  ) {
    if (_cart == null) return;

    final products =
        List<CartProduct>.from(
      _cart!.products,
    );

    final index =
        products.indexWhere(
      (item) => item.id == productId,
    );

    if (index < 0) return;

    final old =
        products[index];

    final newQuantity =
        old.quantity - 1;

    if (newQuantity <= 0) {
      products.removeAt(index);
    } else {
      products[index] = CartProduct(
        id: old.id,
        title: old.title,
        price: old.price,
        quantity: newQuantity,
        total:
            old.price * newQuantity,
        discountPercentage:
            old.discountPercentage,
        discountedTotal: old.price *
            newQuantity *
            (1 -
                old.discountPercentage /
                    100),
        thumbnail: old.thumbnail,
      );
    }

    _updateCart(products);
  }

  void _updateCart(
    List<CartProduct> products,
  ) {
    final total =
        products.fold<double>(
      0.0,
      (sum, item) =>
          sum + item.total,
    );

    final discountedTotal =
        products.fold<double>(
      0.0,
      (sum, item) =>
          sum + item.discountedTotal,
    );

    final totalQuantity =
        products.fold<int>(
      0,
      (sum, item) =>
          sum + item.quantity,
    );

    _cart = Cart(
      id: _cart?.id ?? 0,
      products: products,
      total: total,
      discountedTotal:
          discountedTotal,
      userId: _userId,
      totalProducts:
          products.length,
      totalQuantity:
          totalQuantity,
    );
  }

  void clearCart() {
    _cart = Cart(
      id: 0,
      products: [],
      total: 0.0,
      discountedTotal: 0.0,
      userId: _userId,
      totalProducts: 0,
      totalQuantity: 0,
    );

    notifyListeners();
  }
}