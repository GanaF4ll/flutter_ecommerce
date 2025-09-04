import 'package:http/http.dart' as http;

class ProductRepository {
  Future<http.Response> fetchProducts() {
    return http.get(Uri.parse('https://fakestoreapi.com/products'));
  }

  Future<http.Response> fetchProductById(String id) {
    return http.get(Uri.parse('https://fakestoreapi.com/products/$id'));
  }
}
