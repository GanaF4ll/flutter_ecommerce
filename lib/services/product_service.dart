import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final ProductRepository? _productRepository;

  ProductService({ProductRepository? productRepository})
      : _productRepository = productRepository;
  Future<http.Response> fetchProducts() {
    return http.get(Uri.parse('https://fakestoreapi.com/products'));
  }

  Future<http.Response> fetchProductById(String id) {
    return http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
  }

  /// The function fetches local products data from a JSON file using rootBundle in Dart.
  ///
  /// Returns:
  ///   A Future&lt;String&gt; containing the JSON data.
  Future<String> fetchLocalProducts() async {
    return await rootBundle.loadString('lib/data/products.json');
  }

  /// This Dart function fetches a local product by ID from a JSON file and returns the product as a JSON
  /// string or throws an exception if the product is not found.
  ///
  /// Args:
  ///   id (String): The `fetchLocalProductById` function is designed to fetch a product by its ID from a
  /// local JSON file. The `id` parameter represents the unique identifier of the product you want to
  /// retrieve. When you call this function with a specific `id`, it will search for a product in the JSON
  ///
  /// Returns:
  ///   A Future&lt;String&gt; containing the product JSON data.
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

  /// This Dart function fetches local products from a JSON file by category and returns them as a
  /// JSON-encoded string.
  ///
  /// Args:
  ///   category (String): The `fetchLocalProductsByCategory` function you provided reads a JSON file
  /// containing product data, filters the products based on a given category, and returns the filtered
  /// products as a JSON string.
  ///
  /// Returns:
  ///   A Future&lt;String&gt; containing JSON-encoded products for the category.
  Future<String> fetchLocalProductsByCategory(String category) async {
    String jsonString = await rootBundle.loadString('lib/data/products.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> products = jsonData['products'];
    List<dynamic> productsByCategory =
        products.where((product) => product['category'] == category).toList();
    return json.encode(productsByCategory);
  }

  /// Fetch local categories from JSON file
  Future<String> fetchLocalCategories() async {
    return await rootBundle.loadString('lib/data/categories.json');
  }

  /// Get products as List&lt;Product&gt;
  Future<List<Product>> getProducts() async {
    String jsonString = await fetchLocalProducts();
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> productsData = jsonData['products'];
    return productsData.map((json) => Product.fromJson(json)).toList();
  }

  /// Get categories as List&lt;Map&lt;String, String&gt;&gt;
  Future<List<Map<String, String>>> getCategories() async {
    String jsonString = await fetchLocalCategories();
    Map<String, dynamic> jsonData = json.decode(jsonString);
    List<dynamic> categoriesData = jsonData['categories'];
    return categoriesData
        .map(
          (category) => {
            'name': category['name'] as String,
            'slug': category['slug'] as String,
          },
        )
        .toList();
  }

  /// Get products by category as List&lt;Product&gt;
  Future<List<Product>> getProductsByCategory(String category) async {
    String jsonString = await fetchLocalProductsByCategory(category);
    List<dynamic> productsData = json.decode(jsonString);
    return productsData.map((json) => Product.fromJson(json)).toList();
  }

  /// Get product by ID as Product
  Future<Product> getProductById(String id) async {
    String jsonString = await fetchLocalProductById(id);
    Map<String, dynamic> productData = json.decode(jsonString);
    return Product.fromJson(productData);
  }
}
