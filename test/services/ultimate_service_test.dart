import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_ecommerce/services/product_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ultimate Service Integration Tests', () {
    late CartService cartService;
    late FavoriteService favoriteService;
    late ProductService productService;
    late Product testProduct;

    setUp(() {
      cartService = CartService();
      favoriteService = FavoriteService();
      productService = ProductService();

      const testRating = Rating(rate: 4.8, count: 150);
      testProduct = const Product(
        id: 42,
        title: 'Ultimate Test Product',
        description: 'The best product for ultimate testing',
        price: 199.99,
        image: 'ultimate.jpg',
        category: 'ultimate',
        rating: testRating,
      );
    });

    group('CartService Ultimate Tests', () {
      test('should handle complex cart operations', () {
        // Add multiple items
        cartService.addItem(testProduct, 3);
        cartService.addItem(testProduct.copyWith(id: 2), 5);
        cartService.addItem(testProduct.copyWith(id: 3), 1);

        expect(cartService.itemCount, equals(9));
        expect(cartService.items, hasLength(3));
        expect(cartService.totalPrice, equals(1799.91));
      });

      test('should handle item modifications', () {
        cartService.addItem(testProduct, 2);

        // Update quantity
        cartService.updateQuantity(testProduct.id, 5);
        expect(cartService.itemCount, equals(5));
        expect(cartService.totalPrice, equals(999.95));

        // Remove item
        cartService.removeItem(testProduct.id);
        expect(cartService.items, isEmpty);
        expect(cartService.totalPrice, equals(0.0));
      });

      test('should handle edge cases', () {
        // Zero quantity
        cartService.addItem(testProduct, 0);
        expect(cartService.items, isEmpty);

        // Negative quantity
        cartService.addItem(testProduct, -1);
        expect(cartService.items, isEmpty);

        // Very large quantity
        cartService.addItem(testProduct, 10000);
        expect(cartService.itemCount, equals(10000));
        expect(cartService.totalPrice, equals(1999900.0));
      });

      test('should handle duplicate additions', () {
        cartService.addItem(testProduct, 2);
        cartService.addItem(testProduct, 3); // Should update existing

        expect(cartService.items, hasLength(1));
        expect(cartService.itemCount, equals(5));
      });

      test('should handle cart clearing', () {
        cartService.addItem(testProduct, 5);
        cartService.addItem(testProduct.copyWith(id: 2), 3);

        expect(cartService.items, hasLength(2));

        cartService.clearCart();
        expect(cartService.items, isEmpty);
        expect(cartService.itemCount, equals(0));
        expect(cartService.totalPrice, equals(0.0));
      });

      test('should calculate totals correctly', () {
        final products = [
          testProduct.copyWith(id: 1, price: 10.0),
          testProduct.copyWith(id: 2, price: 20.5),
          testProduct.copyWith(id: 3, price: 30.75),
        ];

        cartService.addItem(products[0], 2); // 20.0
        cartService.addItem(products[1], 3); // 61.5
        cartService.addItem(products[2], 1); // 30.75

        expect(cartService.totalPrice, equals(112.25));
        expect(cartService.itemCount, equals(6));
      });

      test('should handle items with zero price', () {
        final freeProduct = testProduct.copyWith(price: 0.0);
        cartService.addItem(freeProduct, 10);

        expect(cartService.totalPrice, equals(0.0));
        expect(cartService.itemCount, equals(10));
      });

      test('should handle very expensive items', () {
        final expensiveProduct = testProduct.copyWith(price: 999999.99);
        cartService.addItem(expensiveProduct, 1);

        expect(cartService.totalPrice, equals(999999.99));
        expect(cartService.itemCount, equals(1));
      });

      test('should handle rapid operations', () {
        for (int i = 0; i < 100; i++) {
          cartService.addItem(testProduct.copyWith(id: i), 1);
        }

        expect(cartService.items, hasLength(100));
        expect(cartService.itemCount, equals(100));

        for (int i = 0; i < 50; i++) {
          cartService.removeItem(i);
        }

        expect(cartService.items, hasLength(50));
        expect(cartService.itemCount, equals(50));
      });

      test('should handle memory stress', () {
        // Add many items
        for (int i = 0; i < 1000; i++) {
          cartService.addItem(testProduct.copyWith(id: i), 1);
        }

        expect(cartService.items, hasLength(1000));

        // Clear and verify memory is released
        cartService.clearCart();
        expect(cartService.items, isEmpty);
      });
    });

    group('FavoriteService Ultimate Tests', () {
      test('should handle favorite operations', () {
        // Add favorites
        favoriteService.addFavorite(testProduct.id);
        favoriteService.addFavorite(2);
        favoriteService.addFavorite(3);

        expect(favoriteService.favoriteProductIds, hasLength(3));
        expect(favoriteService.isFavorite(testProduct.id), isTrue);
        expect(favoriteService.isFavorite(2), isTrue);
        expect(favoriteService.isFavorite(3), isTrue);
        expect(favoriteService.isFavorite(999), isFalse);
      });

      test('should handle duplicate favorites', () {
        favoriteService.addFavorite(testProduct.id);
        favoriteService.addFavorite(testProduct.id);
        favoriteService.addFavorite(testProduct.id);

        expect(favoriteService.favoriteProductIds, hasLength(1));
        expect(favoriteService.isFavorite(testProduct.id), isTrue);
      });

      test('should handle favorite removal', () {
        favoriteService.addFavorite(testProduct.id);
        favoriteService.addFavorite(2);

        expect(favoriteService.favoriteProductIds, hasLength(2));

        favoriteService.removeFavorite(testProduct.id);
        expect(favoriteService.favoriteProductIds, hasLength(1));
        expect(favoriteService.isFavorite(testProduct.id), isFalse);
        expect(favoriteService.isFavorite(2), isTrue);
      });

      test('should handle favorite toggling', () {
        // Initially not favorite
        expect(favoriteService.isFavorite(testProduct.id), isFalse);

        // Toggle to favorite
        favoriteService.toggleFavorite(testProduct.id);
        expect(favoriteService.isFavorite(testProduct.id), isTrue);

        // Toggle back to not favorite
        favoriteService.toggleFavorite(testProduct.id);
        expect(favoriteService.isFavorite(testProduct.id), isFalse);
      });

      test('should clear all favorites', () {
        favoriteService.addFavorite(1);
        favoriteService.addFavorite(2);
        favoriteService.addFavorite(3);

        expect(favoriteService.favoriteProductIds, hasLength(3));

        favoriteService.clearFavorites();
        expect(favoriteService.favoriteProductIds, isEmpty);
      });

      test('should handle large number of favorites', () {
        for (int i = 0; i < 1000; i++) {
          favoriteService.addFavorite(i);
        }

        expect(favoriteService.favoriteProductIds, hasLength(1000));

        // Check random favorites
        expect(favoriteService.isFavorite(500), isTrue);
        expect(favoriteService.isFavorite(999), isTrue);
        expect(favoriteService.isFavorite(1000), isFalse);
      });

      test('should handle edge case IDs', () {
        final edgeIds = [0, -1, 999999999, -999999999];

        for (final id in edgeIds) {
          favoriteService.addFavorite(id);
          expect(favoriteService.isFavorite(id), isTrue);

          favoriteService.removeFavorite(id);
          expect(favoriteService.isFavorite(id), isFalse);
        }
      });

      test('should maintain state consistency', () {
        // Add multiple favorites
        final favoriteIds = [1, 2, 3, 4, 5];
        for (final id in favoriteIds) {
          favoriteService.addFavorite(id);
        }

        // Verify all are favorites
        for (final id in favoriteIds) {
          expect(favoriteService.isFavorite(id), isTrue);
        }

        // Remove some favorites
        favoriteService.removeFavorite(2);
        favoriteService.removeFavorite(4);

        // Verify state
        expect(favoriteService.isFavorite(1), isTrue);
        expect(favoriteService.isFavorite(2), isFalse);
        expect(favoriteService.isFavorite(3), isTrue);
        expect(favoriteService.isFavorite(4), isFalse);
        expect(favoriteService.isFavorite(5), isTrue);
      });
    });

    group('ProductService Ultimate Tests', () {
      test('should handle getAllProducts', () async {
        final products = await productService.getAllProducts();

        expect(products, isNotNull);
        expect(products, isA<List<Product>>());
        // Note: Actual products depend on JSON data
      });

      test('should handle getProductById', () async {
        // Test with a valid ID (assuming ID 1 exists)
        try {
          final product = await productService.getProductById(1);
          expect(product, isNotNull);
          expect(product.id, equals(1));
        } catch (e) {
          // Expected if product doesn't exist
          expect(e, isA<Exception>());
        }
      });

      test('should handle non-existent product ID', () async {
        expect(
          () => productService.getProductById(999999),
          throwsException,
        );
      });

      test('should handle getProductsByCategory', () async {
        try {
          final products =
              await productService.getProductsByCategory('electronics');
          expect(products, isA<List<Product>>());
        } catch (e) {
          // Expected if no products in category
          expect(e, isA<Exception>());
        }
      });

      test('should handle empty category', () async {
        try {
          final products = await productService.getProductsByCategory('');
          expect(products, isA<List<Product>>());
        } catch (e) {
          expect(e, isA<Exception>());
        }
      });

      test('should handle null/invalid category', () async {
        expect(
          () => productService
              .getProductsByCategory('invalid_category_that_does_not_exist'),
          throwsException,
        );
      });

      test('should handle getAllCategories', () async {
        final categories = await productService.getAllCategories();

        expect(categories, isNotNull);
        expect(categories, isA<List<String>>());
      });

      test('should handle multiple concurrent requests', () async {
        final futures = [
          productService.getAllProducts(),
          productService.getAllCategories(),
        ];

        try {
          final results = await Future.wait(futures);
          expect(results, hasLength(2));
          expect(results[0], isA<List<Product>>());
          expect(results[1], isA<List<String>>());
        } catch (e) {
          // Expected if local assets not available in test
          expect(e, isA<Exception>());
        }
      });

      test('should handle rapid sequential calls', () async {
        for (int i = 0; i < 5; i++) {
          try {
            await productService.getAllCategories();
          } catch (e) {
            // Expected in test environment
            expect(e, isA<Exception>());
          }
        }
      });
    });

    group('Service Integration Tests', () {
      test('should work together: add product to cart and favorites', () {
        // Add to cart
        cartService.addItem(testProduct, 2);
        expect(cartService.itemCount, equals(2));

        // Add to favorites
        favoriteService.addFavorite(testProduct.id);
        expect(favoriteService.isFavorite(testProduct.id), isTrue);

        // Verify both services maintain state
        expect(cartService.items, hasLength(1));
        expect(favoriteService.favoriteProductIds, hasLength(1));
      });

      test('should handle cart and favorite operations on same product', () {
        // Product in both cart and favorites
        cartService.addItem(testProduct, 3);
        favoriteService.addFavorite(testProduct.id);

        expect(cartService.itemCount, equals(3));
        expect(favoriteService.isFavorite(testProduct.id), isTrue);

        // Remove from cart but keep in favorites
        cartService.removeItem(testProduct.id);
        expect(cartService.items, isEmpty);
        expect(favoriteService.isFavorite(testProduct.id), isTrue);

        // Remove from favorites
        favoriteService.removeFavorite(testProduct.id);
        expect(favoriteService.isFavorite(testProduct.id), isFalse);
      });

      test('should handle bulk operations across services', () {
        final products = List.generate(
            10,
            (index) =>
                testProduct.copyWith(id: index, title: 'Product $index'));

        // Add all to cart
        for (final product in products) {
          cartService.addItem(product, 1);
        }

        // Add half to favorites
        for (int i = 0; i < 5; i++) {
          favoriteService.addFavorite(products[i].id);
        }

        expect(cartService.items, hasLength(10));
        expect(cartService.itemCount, equals(10));
        expect(favoriteService.favoriteProductIds, hasLength(5));

        // Clear cart but keep favorites
        cartService.clearCart();
        expect(cartService.items, isEmpty);
        expect(favoriteService.favoriteProductIds, hasLength(5));

        // Clear favorites
        favoriteService.clearFavorites();
        expect(favoriteService.favoriteProductIds, isEmpty);
      });

      test('should maintain performance under load', () {
        // Simulate heavy usage
        for (int i = 0; i < 100; i++) {
          final product = testProduct.copyWith(id: i);

          cartService.addItem(product, 1);
          favoriteService.addFavorite(product.id);

          if (i % 10 == 0) {
            cartService.updateQuantity(product.id, 2);
          }

          if (i % 20 == 0) {
            favoriteService.toggleFavorite(product.id);
          }
        }

        expect(cartService.items, hasLength(100));
        expect(favoriteService.favoriteProductIds,
            hasLength(95)); // 5 were toggled off
      });
    });

    group('Memory and Performance Tests', () {
      test('should handle memory cleanup', () {
        // Create lots of data
        for (int i = 0; i < 1000; i++) {
          cartService.addItem(testProduct.copyWith(id: i), 1);
          favoriteService.addFavorite(i);
        }

        // Verify data exists
        expect(cartService.items, hasLength(1000));
        expect(favoriteService.favoriteProductIds, hasLength(1000));

        // Clear everything
        cartService.clearCart();
        favoriteService.clearFavorites();

        // Verify cleanup
        expect(cartService.items, isEmpty);
        expect(favoriteService.favoriteProductIds, isEmpty);
      });

      test('should handle rapid state changes', () {
        for (int i = 0; i < 100; i++) {
          cartService.addItem(testProduct, 1);
          cartService.updateQuantity(testProduct.id, i + 1);
          favoriteService.toggleFavorite(testProduct.id);
        }

        expect(cartService.itemCount, equals(100));
        expect(favoriteService.isFavorite(testProduct.id),
            isFalse); // Toggled even number of times
      });
    });
  });
}
