import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ProductService {
  /// The function `fetchProducts` makes an HTTP GET request to retrieve products from a fake store API.
  ///
  /// Returns:
  ///   A Future object containing an HTTP Response is being returned.
  Future<http.Response> fetchProducts() {
    return http.get(Uri.parse('https://fakestoreapi.com/products'));
  }

  /// The function `fetchProductById` retrieves product information from a specified API endpoint using
  /// the provided product ID.
  ///
  /// Args:
  ///   id (String): The `id` parameter in the `fetchProductById` function is a unique identifier for a
  /// product. It is used to fetch product information from the API by appending it to the URL endpoint.
  ///
  /// Returns:
  ///   A Future object containing an HTTP response is being returned.
  Future<http.Response> fetchProductById(String id) {
    return http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
  }

  Future<String> fetchLocalProducts() async {
    return await rootBundle.loadString('lib/data/products.json');
  }

  Future<String> fetchLocalProductById(String id) async {
    String jsonString = await rootBundle.loadString('lib/data/products.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> products = jsonData['products'];

    var product = products.firstWhere(
      (product) => product['id'].toString() == id,
      orElse: () => null,
    );

    if (product != null) {
      return json.encode(product);
    } else {
      throw Exception('Product with ID $id not found');
    }
  }
}
