import 'dart:convert';

import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/services/product_service.dart';
import 'package:http/http.dart' as http;

class ProductRepository {
  final ProductService _productService = ProductService();

  /// This Dart function fetches a product by its ID asynchronously and handles errors appropriately.
  ///
  /// Args:
  ///   id (String): The `id` parameter in the `fetchProductById` function is the unique identifier of the
  /// product that you want to fetch from the server. This function makes an asynchronous HTTP request to
  /// retrieve product data based on this identifier.
  ///
  /// Returns:
  ///   A Future object containing a Product is being returned.
  Future<Product> fetchProductById(String id) async {
    try {
      http.Response response = await _productService.fetchProductById(id);
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Product $id not found');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  /// The function `fetchProducts` asynchronously retrieves product data from a service, processes it, and
  /// returns a list of Product objects, handling potential errors along the way.
  ///
  /// Returns:
  ///   A `Future<List<Product>>` is being returned from the `fetchProducts` function.
  Future<List<Product>> fetchProducts() async {
    try {
      http.Response response = await _productService.fetchProducts();
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Product>> fetchLocalProducts() async {
    try {
      String jsonString = await _productService.fetchLocalProducts();
      Map<String, dynamic> jsonData = json.decode(jsonString);
      List<dynamic> products = jsonData['products'];
      return products.map((item) => Product.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error fetching local products: $e');
    }
  }

  Future<Product> fetchLocalProductById(String id) async {
    try {
      String jsonString = await _productService.fetchLocalProductById(id);
      return Product.fromJson(json.decode(jsonString));
    } catch (e) {
      throw Exception('Error fetching local product: $e');
    }
  }
}
