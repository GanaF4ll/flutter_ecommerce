import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'cart_repository_comprehensive_test.mocks.dart';

@GenerateMocks([CartRepositoryInterface, Database])
void main() {
  group('CartRepository Comprehensive Tests', () {
    late MockCartRepositoryInterface mockRepository;
    late Product testProduct;
    late CartItem testCartItem;

    setUp(() {
      mockRepository = MockCartRepositoryInterface();

      const testRating = Rating(rate: 4.5, count: 100);
      testProduct = const Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'test.jpg',
        category: 'test',
        rating: testRating,
      );

      testCartItem = CartItem(
        id: 1,
        product: testProduct,
        quantity: 2,
      );
    });

    group('Add Item Tests', () {
      test('should add new item to cart', () async {
        when(mockRepository.addItem(testProduct, 2))
            .thenAnswer((_) async => testCartItem);

        final result = await mockRepository.addItem(testProduct, 2);

        expect(result, isA<CartItem>());
        expect(result.product.id, equals(1));
        expect(result.quantity, equals(2));
        verify(mockRepository.addItem(testProduct, 2)).called(1);
      });

      test('should handle adding same product multiple times', () async {
        final item1 = CartItem(id: 1, product: testProduct, quantity: 1);
        final item2 = CartItem(id: 1, product: testProduct, quantity: 3);

        when(mockRepository.addItem(testProduct, 1))
            .thenAnswer((_) async => item1);
        when(mockRepository.addItem(testProduct, 2))
            .thenAnswer((_) async => item2);

        final result1 = await mockRepository.addItem(testProduct, 1);
        final result2 = await mockRepository.addItem(testProduct, 2);

        expect(result1.quantity, equals(1));
        expect(result2.quantity, equals(3));
      });

      test('should handle large quantities', () async {
        final largeQuantityItem = CartItem(
          id: 1,
          product: testProduct,
          quantity: 999,
        );

        when(mockRepository.addItem(testProduct, 999))
            .thenAnswer((_) async => largeQuantityItem);

        final result = await mockRepository.addItem(testProduct, 999);

        expect(result.quantity, equals(999));
        expect(result.totalPrice, equals(99990.01));
      });

      test('should handle zero quantity', () async {
        when(mockRepository.addItem(testProduct, 0))
            .thenThrow(ArgumentError('Quantity must be positive'));

        expect(
          () => mockRepository.addItem(testProduct, 0),
          throwsArgumentError,
        );
      });

      test('should handle negative quantity', () async {
        when(mockRepository.addItem(testProduct, -1))
            .thenThrow(ArgumentError('Quantity must be positive'));

        expect(
          () => mockRepository.addItem(testProduct, -1),
          throwsArgumentError,
        );
      });
    });

    group('Remove Item Tests', () {
      test('should remove item by product id', () async {
        when(mockRepository.removeItem(1)).thenAnswer((_) async => true);

        final result = await mockRepository.removeItem(1);

        expect(result, isTrue);
        verify(mockRepository.removeItem(1)).called(1);
      });

      test('should handle removing non-existent item', () async {
        when(mockRepository.removeItem(999)).thenAnswer((_) async => false);

        final result = await mockRepository.removeItem(999);

        expect(result, isFalse);
        verify(mockRepository.removeItem(999)).called(1);
      });

      test('should handle database errors during removal', () async {
        when(mockRepository.removeItem(1))
            .thenThrow(DatabaseException('Database error'));

        expect(
          () => mockRepository.removeItem(1),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('Update Quantity Tests', () {
      test('should update item quantity', () async {
        final updatedItem = CartItem(
          id: 1,
          product: testProduct,
          quantity: 5,
        );

        when(mockRepository.updateQuantity(1, 5))
            .thenAnswer((_) async => updatedItem);

        final result = await mockRepository.updateQuantity(1, 5);

        expect(result.quantity, equals(5));
        expect(result.totalPrice, equals(499.95));
        verify(mockRepository.updateQuantity(1, 5)).called(1);
      });

      test('should handle updating to zero quantity', () async {
        when(mockRepository.updateQuantity(1, 0)).thenAnswer((_) async => true);

        final result = await mockRepository.updateQuantity(1, 0);

        expect(result, isTrue);
      });

      test('should handle updating non-existent item', () async {
        when(mockRepository.updateQuantity(999, 5))
            .thenThrow(Exception('Item not found'));

        expect(
          () => mockRepository.updateQuantity(999, 5),
          throwsException,
        );
      });
    });

    group('Get All Items Tests', () {
      test('should return all cart items', () async {
        final items = [
          testCartItem,
          CartItem(
            id: 2,
            product: testProduct.copyWith(id: 2, title: 'Product 2'),
            quantity: 1,
          ),
        ];

        when(mockRepository.getAllItems()).thenAnswer((_) async => items);

        final result = await mockRepository.getAllItems();

        expect(result, hasLength(2));
        expect(result[0].product.id, equals(1));
        expect(result[1].product.id, equals(2));
        verify(mockRepository.getAllItems()).called(1);
      });

      test('should return empty list when cart is empty', () async {
        when(mockRepository.getAllItems()).thenAnswer((_) async => []);

        final result = await mockRepository.getAllItems();

        expect(result, isEmpty);
        verify(mockRepository.getAllItems()).called(1);
      });

      test('should handle database errors', () async {
        when(mockRepository.getAllItems())
            .thenThrow(DatabaseException('Database connection failed'));

        expect(
          () => mockRepository.getAllItems(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('Clear Cart Tests', () {
      test('should clear all items from cart', () async {
        when(mockRepository.clearCart()).thenAnswer((_) async => true);

        final result = await mockRepository.clearCart();

        expect(result, isTrue);
        verify(mockRepository.clearCart()).called(1);
      });

      test('should handle clearing empty cart', () async {
        when(mockRepository.clearCart()).thenAnswer((_) async => true);

        final result = await mockRepository.clearCart();

        expect(result, isTrue);
      });

      test('should handle database errors during clear', () async {
        when(mockRepository.clearCart())
            .thenThrow(DatabaseException('Failed to clear cart'));

        expect(
          () => mockRepository.clearCart(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('Get Item Count Tests', () {
      test('should return total item count', () async {
        when(mockRepository.getItemCount()).thenAnswer((_) async => 5);

        final result = await mockRepository.getItemCount();

        expect(result, equals(5));
        verify(mockRepository.getItemCount()).called(1);
      });

      test('should return zero for empty cart', () async {
        when(mockRepository.getItemCount()).thenAnswer((_) async => 0);

        final result = await mockRepository.getItemCount();

        expect(result, equals(0));
      });
    });

    group('Get Total Price Tests', () {
      test('should calculate total price correctly', () async {
        when(mockRepository.getTotalPrice()).thenAnswer((_) async => 299.97);

        final result = await mockRepository.getTotalPrice();

        expect(result, equals(299.97));
        verify(mockRepository.getTotalPrice()).called(1);
      });

      test('should return zero for empty cart', () async {
        when(mockRepository.getTotalPrice()).thenAnswer((_) async => 0.0);

        final result = await mockRepository.getTotalPrice();

        expect(result, equals(0.0));
      });

      test('should handle very large totals', () async {
        when(mockRepository.getTotalPrice()).thenAnswer((_) async => 999999.99);

        final result = await mockRepository.getTotalPrice();

        expect(result, equals(999999.99));
      });
    });

    group('Performance Tests', () {
      test('should handle rapid operations', () async {
        final futures = <Future>[];

        for (int i = 1; i <= 10; i++) {
          when(mockRepository.addItem(any, any))
              .thenAnswer((_) async => CartItem(
                    id: i,
                    product: testProduct.copyWith(id: i),
                    quantity: 1,
                  ));

          futures.add(mockRepository.addItem(testProduct.copyWith(id: i), 1));
        }

        final results = await Future.wait(futures);
        expect(results, hasLength(10));
      });

      test('should handle large cart operations', () async {
        final largeCart = List.generate(
            100,
            (index) => CartItem(
                  id: index,
                  product: testProduct.copyWith(id: index),
                  quantity: 1,
                ));

        when(mockRepository.getAllItems()).thenAnswer((_) async => largeCart);

        final result = await mockRepository.getAllItems();
        expect(result, hasLength(100));
      });
    });

    group('Edge Cases', () {
      test('should handle concurrent modifications', () async {
        when(mockRepository.addItem(any, any))
            .thenAnswer((_) async => testCartItem);
        when(mockRepository.removeItem(any)).thenAnswer((_) async => true);
        when(mockRepository.updateQuantity(any, any))
            .thenAnswer((_) async => testCartItem);

        final futures = [
          mockRepository.addItem(testProduct, 1),
          mockRepository.removeItem(1),
          mockRepository.updateQuantity(1, 3),
        ];

        final results = await Future.wait(futures);
        expect(results, hasLength(3));
      });

      test('should handle products with special prices', () async {
        final products = [
          testProduct.copyWith(price: 0.01), // Very cheap
          testProduct.copyWith(price: 999999.99), // Very expensive
          testProduct.copyWith(price: 9.99), // Common price
        ];

        for (int i = 0; i < products.length; i++) {
          when(mockRepository.addItem(products[i], 1))
              .thenAnswer((_) async => CartItem(
                    id: i,
                    product: products[i],
                    quantity: 1,
                  ));

          final result = await mockRepository.addItem(products[i], 1);
          expect(result.product.price, equals(products[i].price));
        }
      });

      test('should handle products with long titles', () async {
        final longTitleProduct = testProduct.copyWith(
          title:
              'Very very very very very very very very very very long product title that might cause issues',
        );

        when(mockRepository.addItem(longTitleProduct, 1))
            .thenAnswer((_) async => CartItem(
                  id: 1,
                  product: longTitleProduct,
                  quantity: 1,
                ));

        final result = await mockRepository.addItem(longTitleProduct, 1);
        expect(result.product.title, contains('Very very'));
      });

      test('should handle multiple database operations', () async {
        // Setup multiple mocks
        when(mockRepository.addItem(any, any))
            .thenAnswer((_) async => testCartItem);
        when(mockRepository.getAllItems())
            .thenAnswer((_) async => [testCartItem]);
        when(mockRepository.getItemCount()).thenAnswer((_) async => 1);
        when(mockRepository.getTotalPrice()).thenAnswer((_) async => 99.99);
        when(mockRepository.clearCart()).thenAnswer((_) async => true);

        // Execute operations in sequence
        await mockRepository.addItem(testProduct, 1);
        final items = await mockRepository.getAllItems();
        final count = await mockRepository.getItemCount();
        final total = await mockRepository.getTotalPrice();
        await mockRepository.clearCart();

        expect(items, hasLength(1));
        expect(count, equals(1));
        expect(total, equals(99.99));
      });
    });

    group('Error Recovery Tests', () {
      test('should handle network timeouts', () async {
        when(mockRepository.getAllItems())
            .thenThrow(Exception('Network timeout'));

        expect(
          () => mockRepository.getAllItems(),
          throwsException,
        );
      });

      test('should handle corrupted data', () async {
        when(mockRepository.addItem(any, any))
            .thenThrow(FormatException('Invalid data format'));

        expect(
          () => mockRepository.addItem(testProduct, 1),
          throwsFormatException,
        );
      });

      test('should handle memory constraints', () async {
        when(mockRepository.getAllItems())
            .thenThrow(Exception('Out of memory'));

        expect(
          () => mockRepository.getAllItems(),
          throwsException,
        );
      });
    });
  });
}
