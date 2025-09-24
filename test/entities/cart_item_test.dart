import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartItem Entity Tests', () {
    late Product testProduct;
    late CartItem testCartItem;

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

      testCartItem = CartItem(id: 1, product: testProduct, quantity: 2);
    });

    test('should create a CartItem with all required fields', () {
      expect(testCartItem.id, 1);
      expect(testCartItem.product.id, 1);
      expect(testCartItem.quantity, 2);
      expect(testCartItem.product, testProduct);
    });

    test('should calculate total price correctly', () {
      expect(testCartItem.totalPrice, 199.98); // 99.99 * 2
    });

    test('should create CartItem from Map correctly', () {
      final map = {'id': 1, 'product_id': 1, 'quantity': 2};

      final cartItem = CartItem.fromMap(map, testProduct);

      expect(cartItem.id, 1);
      expect(cartItem.product.id, 1);
      expect(cartItem.quantity, 2);
      expect(cartItem.product, testProduct);
    });

    test('should convert to Map correctly', () {
      final map = testCartItem.toMap();

      expect(map['id'], 1);
      expect(map['product_id'], 1);
      expect(map['quantity'], 2);
    });

    test('should create copyWith correctly', () {
      final newCartItem = testCartItem.copyWith(quantity: 3);

      expect(newCartItem.id, 1);
      expect(newCartItem.product.id, 1);
      expect(newCartItem.quantity, 3);
      expect(newCartItem.product, testProduct);
      expect(newCartItem.totalPrice, 299.97); // 99.99 * 3
    });

    test('should maintain same values when copyWith with no changes', () {
      final newCartItem = testCartItem.copyWith();

      expect(newCartItem.id, testCartItem.id);
      expect(newCartItem.product.id, testCartItem.product.id);
      expect(newCartItem.quantity, testCartItem.quantity);
      expect(newCartItem.product, testCartItem.product);
    });

    test('should support equality comparison', () {
      final cartItem1 = CartItem(id: 1, product: testProduct, quantity: 2);

      final cartItem2 = CartItem(id: 1, product: testProduct, quantity: 2);

      final cartItem3 = CartItem(id: 2, product: testProduct, quantity: 2);

      expect(cartItem1, equals(cartItem2));
      expect(cartItem1, isNot(equals(cartItem3)));
    });

    test('should have proper string representation', () {
      final stringRepresentation = testCartItem.toString();

      expect(stringRepresentation, contains('1'));
      expect(stringRepresentation, contains('2'));
    });

    test('should handle zero quantity', () {
      final cartItem = testCartItem.copyWith(quantity: 0);

      expect(cartItem.totalPrice, 0.0);
    });

    test('should handle negative quantity', () {
      final cartItem = testCartItem.copyWith(quantity: -1);

      expect(cartItem.totalPrice, -99.99);
    });
  });
}
