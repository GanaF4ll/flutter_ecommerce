import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Favorite Entity Tests', () {
    late Product testProduct;
    late Favorite testFavorite;
    late DateTime testDate;

    setUp(() {
      const testRating = Rating(rate: 4.5, count: 100);
      testProduct = const Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: testRating,
      );

      testDate = DateTime.now();
      testFavorite = Favorite(
        id: 1,
        productId: 1,
        product: testProduct,
        addedAt: testDate,
      );
    });

    test('should create a Favorite with all required fields', () {
      expect(testFavorite.id, 1);
      expect(testFavorite.productId, 1);
      expect(testFavorite.product, testProduct);
      expect(testFavorite.addedAt, testDate);
    });

    test('should create Favorite from Map correctly', () {
      final map = {
        'id': 1,
        'product_id': 1,
        'added_at': testDate.toIso8601String(),
      };

      final favorite = Favorite.fromMap(map, product: testProduct);

      expect(favorite.id, 1);
      expect(favorite.productId, 1);
      expect(favorite.product, testProduct);
      expect(favorite.addedAt, testDate);
    });

    test('should convert to Map correctly', () {
      final map = testFavorite.toMap();

      expect(map['id'], 1);
      expect(map['product_id'], 1);
      expect(map['added_at'], testDate.toIso8601String());
    });

    test('should create copyWith correctly', () {
      final newDate = DateTime.now().add(const Duration(days: 1));
      final newFavorite = testFavorite.copyWith(addedAt: newDate);

      expect(newFavorite.id, 1);
      expect(newFavorite.productId, 1);
      expect(newFavorite.product, testProduct);
      expect(newFavorite.addedAt, newDate);
    });

    test('should maintain same values when copyWith with no changes', () {
      final newFavorite = testFavorite.copyWith();

      expect(newFavorite.id, testFavorite.id);
      expect(newFavorite.productId, testFavorite.productId);
      expect(newFavorite.product, testFavorite.product);
      expect(newFavorite.addedAt, testFavorite.addedAt);
    });

    test('should support equality comparison based on productId', () {
      final favorite1 = Favorite(
        id: 1,
        productId: 1,
        product: testProduct,
        addedAt: testDate,
      );

      final favorite2 = Favorite(
        id: 2, // Different ID
        productId: 1, // Same productId
        product: testProduct,
        addedAt: testDate,
      );

      final favorite3 = Favorite(
        id: 1,
        productId: 2, // Different productId
        product: testProduct,
        addedAt: testDate,
      );

      expect(favorite1, equals(favorite2)); // Same productId
      expect(favorite1, isNot(equals(favorite3))); // Different productId
    });

    test('should have consistent hashCode based on productId', () {
      final favorite1 = Favorite(
        id: 1,
        productId: 1,
        product: testProduct,
        addedAt: testDate,
      );

      final favorite2 = Favorite(
        id: 2,
        productId: 1, // Same productId
        product: testProduct,
        addedAt: testDate,
      );

      expect(favorite1.hashCode, equals(favorite2.hashCode));
    });

    test('should have proper string representation', () {
      final stringRepresentation = testFavorite.toString();

      expect(stringRepresentation, contains('1'));
      expect(stringRepresentation, contains(testDate.toString()));
    });

    test('should create Favorite without product', () {
      final favorite = Favorite(id: 1, productId: 1, addedAt: testDate);

      expect(favorite.id, 1);
      expect(favorite.productId, 1);
      expect(favorite.product, null);
      expect(favorite.addedAt, testDate);
    });

    test('should handle Favorite without id', () {
      final favorite = Favorite(
        productId: 1,
        product: testProduct,
        addedAt: testDate,
      );

      expect(favorite.id, null);
      expect(favorite.productId, 1);
      expect(favorite.product, testProduct);
      expect(favorite.addedAt, testDate);
    });

    test('should parse ISO date string correctly', () {
      final dateString = '2023-12-01T10:30:00.000Z';
      final map = {'id': 1, 'product_id': 1, 'added_at': dateString};

      final favorite = Favorite.fromMap(map);

      expect(favorite.addedAt, DateTime.parse(dateString));
    });
  });
}
