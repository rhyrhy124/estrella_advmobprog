import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

// This service is responsible for communicating with the DummyJSON cart API.
class CartService {

  // This gets the existing cart of a user from DummyJSON.
  Future<Cart> getCartByUserId(
    int userId,
  ) async {
    try {
      final response =
          await http
              .get(
        Uri.parse(
          '$host/carts/user/$userId',
        ),
      )
              .timeout(
        const Duration(
          seconds: 15,
        ),
        onTimeout: () {
          throw Exception(
            'Request timed out while loading your cart. Please try again.',
          );
        },
      );

      if (response.statusCode ==
          200) {
        final Map<String,
                dynamic>
            data = jsonDecode(
          response.body,
        );

        final List carts =
            data['carts'] ?? [];

        if (carts.isEmpty) {
          return Cart(
            id: 0,
            products: [],
            total: 0.0,
            discountedTotal:
                0.0,
            userId: userId,
            totalProducts: 0,
            totalQuantity: 0,
          );
        }

        return Cart.fromJson(
          carts.first,
        );
      }

      throw Exception(
        'Failed to load cart (status ${response.statusCode}).',
      );
    } on FormatException {
      throw Exception(
        'Received an invalid response from the server while loading the cart.',
      );
    } catch (e) {
      // Re-throw with the original message so the
      // UI layer can show a friendly error.
      rethrow;
    }
  }

  // This sends the Add to Cart request to DummyJSON.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    try {
      // This sends a POST request to:
      // https://dummyjson.com/carts/add
      final response =
          await http
              .post(
        Uri.parse(
          '$host/carts/add',
        ),

        headers: {
          'Content-Type':
              'application/json',
        },

        body: jsonEncode({
          'userId': userId,

          'products': [
            {
              'id': productId,
              'quantity': quantity,
            },
          ],
        }),
      )
              .timeout(
        const Duration(
          seconds: 15,
        ),
        onTimeout: () {
          throw Exception(
            'Request timed out while adding the product to your cart.',
          );
        },
      );

      // DummyJSON returns 201 Created when the cart is successfully added.
      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        final Map<String,
                dynamic>
            data = jsonDecode(
          response.body,
        );

        return Cart.fromJson(data);
      }

      // This gives us the actual API response if something goes wrong.
      throw Exception(
        'Failed to add product to cart. '
        'Status: ${response.statusCode}. '
        'Response: ${response.body}',
      );
    } on FormatException {
      throw Exception(
        'Received an invalid response from the server while adding to cart.',
      );
    } catch (e) {
      rethrow;
    }
  }
}