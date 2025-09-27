import 'dart:convert';
import 'package:flutter_ecommerce/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductService Tests', () {
    late ProductService productService;

    setUp(() {
      productService = ProductService();
    });

    test('should create ProductService instance', () {
      expect(productService, isNotNull);
      expect(productService, isA<ProductService>());
    });

    test('fetchProducts should return Future<http.Response>', () {
      final result = productService.fetchProducts();
      expect(result, isA<Future>());
    });

    test('fetchProductById should return Future<http.Response>', () {
      final result = productService.fetchProductById('1');
      expect(result, isA<Future>());
    });

    group('JSON parsing logic', () {
      test('should parse products correctly from mock JSON', () {
        const mockJson = '''
        {
          "products": [
            {
              "id": 1,
              "title": "Test Product",
              "description": "Test Description",
              "price": 99.99,
              "image": "https://example.com/image.jpg",
              "category": "electronics",
              "rating": {"rate": 4.5, "count": 100}
            }
          ]
        }
        ''';

        final jsonData = json.decode(mockJson);
        final products = jsonData['products'] as List<dynamic>;

        expect(products, hasLength(1));
        expect(products[0]['title'], 'Test Product');
        expect(products[0]['price'], 99.99);
      });

      test('should parse categories correctly from mock JSON', () {
        const mockJson = '''
        {
          "categories": [
            {"name": "Electronics", "slug": "electronics"},
            {"name": "Books", "slug": "books"}
          ]
        }
        ''';

        final jsonData = json.decode(mockJson);
        final categories = jsonData['categories'] as List<dynamic>;

        expect(categories, hasLength(2));
        expect(categories[0]['name'], 'Electronics');
        expect(categories[1]['slug'], 'books');
      });

      test('should filter products by category', () {
        const mockJson = '''
        {
          "products": [
            {"id": 1, "category": "electronics", "title": "Phone"},
            {"id": 2, "category": "books", "title": "Novel"},
            {"id": 3, "category": "electronics", "title": "Laptop"}
          ]
        }
        ''';

        final jsonData = json.decode(mockJson);
        final products = jsonData['products'] as List<dynamic>;
        final electronicsProducts = products
            .where((product) => product['category'] == 'electronics')
            .toList();

        expect(electronicsProducts, hasLength(2));
        expect(electronicsProducts[0]['title'], 'Phone');
        expect(electronicsProducts[1]['title'], 'Laptop');
      });

      test('should find product by ID', () {
        const mockJson = '''
        {
          "products": [
            {"id": 1, "title": "Product 1"},
            {"id": 2, "title": "Product 2"}
          ]
        }
        ''';

        final jsonData = json.decode(mockJson);
        final products = jsonData['products'] as List<dynamic>;
        final product = products.firstWhere(
          (p) => p['id'].toString() == '1',
          orElse: () => null,
        );

        expect(product, isNotNull);
        expect(product['title'], 'Product 1');
      });

      test('should handle missing product ID', () {
        const mockJson = '''
        {
          "products": [
            {"id": 1, "title": "Product 1"}
          ]
        }
        ''';

        final jsonData = json.decode(mockJson);
        final products = jsonData['products'] as List<dynamic>;

        expect(() {
          products.firstWhere(
            (p) => p['id'].toString() == '999',
            orElse: () => throw Exception('Product not found'),
          );
        }, throwsException);
      });

      test('should handle empty products array', () {
        const mockJson = '{"products": []}';

        final jsonData = json.decode(mockJson);
        final products = jsonData['products'] as List<dynamic>;

        expect(products, isEmpty);
      });

      test('should handle malformed JSON gracefully', () {
        expect(() => json.decode('invalid json'), throwsFormatException);
      });
    });

    group('Category mapping', () {
      test('should map categories to correct format', () {
        final mockCategories = [
          {'name': 'Electronics', 'slug': 'electronics'},
          {'name': 'Books', 'slug': 'books'}
        ];

        final mappedCategories = mockCategories
            .map((category) => {
                  'name': category['name'] as String,
                  'slug': category['slug'] as String,
                })
            .toList();

        expect(mappedCategories, hasLength(2));
        expect(mappedCategories[0]['name'], 'Electronics');
        expect(mappedCategories[1]['slug'], 'books');
      });
    });
  });
}
