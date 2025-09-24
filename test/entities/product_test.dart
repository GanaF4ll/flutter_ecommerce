import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Entity Tests', () {
    late Product testProduct;
    late Rating testRating;

    setUp(() {
      testRating = const Rating(rate: 4.5, count: 100);
      testProduct = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: testRating,
      );
    });

    test('should create a Product with all required fields', () {
      expect(testProduct.id, 1);
      expect(testProduct.title, 'Test Product');
      expect(testProduct.description, 'Test Description');
      expect(testProduct.price, 99.99);
      expect(testProduct.image, 'https://example.com/image.jpg');
      expect(testProduct.category, 'electronics');
      expect(testProduct.rating, testRating);
    });

    test('should create Product from JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'Test Description',
        'price': 99.99,
        'image': 'https://example.com/image.jpg',
        'category': 'electronics',
        'rating': {'rate': 4.5, 'count': 100},
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'Test Description');
      expect(product.price, 99.99);
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.category, 'electronics');
      expect(product.rating.rate, 4.5);
      expect(product.rating.count, 100);
    });

    test('should handle invalid JSON gracefully', () {
      final json = <String, dynamic>{};

      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.description, '');
      expect(product.price, 0.0);
      expect(product.image, '');
      expect(product.category, '');
      expect(product.rating.rate, 0.0);
      expect(product.rating.count, 0);
    });

    test('should convert to JSON correctly', () {
      final json = testProduct.toJson();

      expect(json, {'title': 'Test Product'});
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': null,
        'title': null,
        'description': null,
        'price': null,
        'image': null,
        'category': null,
        'rating': null,
      };

      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.description, '');
      expect(product.price, 0.0);
      expect(product.image, '');
      expect(product.category, '');
    });

    test('should handle price as int in JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'Test Description',
        'price': 100, // int instead of double
        'image': 'https://example.com/image.jpg',
        'category': 'electronics',
        'rating': {'rate': 4.5, 'count': 100},
      };

      final product = Product.fromJson(json);

      expect(product.price, 100.0);
    });
  });
}
