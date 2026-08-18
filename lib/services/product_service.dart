import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product.dart';

// This service is used to get product data from the API.
class ProductService {

  // This function gets all products from the API.
  Future<List<Product>> getAllProducts() async {

    // This sends a GET request to the products API.
    final response = await http.get(
      Uri.parse('$host/products'),
    );

    // This checks if the request was successful.
    if (response.statusCode == 200) {

      // This converts the response body from JSON into a Map.
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      // This gets the products list from the API response.
      final List productsJson =
          data['products'] ?? [];

      // This converts each JSON product into a Product object.
      return productsJson
          .map(
            (json) => Product.fromJson(json),
          )
          .toList();

    } else {
      // This shows an error when the API request fails.
      throw Exception(
        'Failed to load products',
      );
    }
  }
}