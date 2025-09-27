import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entity Edge Cases Tests', () {
    group('Product Edge Cases', () {
      test('Product with minimum values', () {
        const rating = Rating(rate: 0.0, count: 0);
        const product = Product(
          id: 0,
          title: '',
          description: '',
          price: 0.0,
          image: '',
          category: '',
          rating: rating,
        );

        expect(product.id, equals(0));
        expect(product.title, equals(''));
        expect(product.price, equals(0.0));
        expect(product.rating.rate, equals(0.0));
      });

      test('Product with maximum rating', () {
        const rating = Rating(rate: 5.0, count: 999999);
        const product = Product(
          id: 999999,
          title: 'Maximum Product',
          description: 'Max description',
          price: 999999.99,
          image: 'max.jpg',
          category: 'max',
          rating: rating,
        );

        expect(product.rating.rate, equals(5.0));
        expect(product.rating.count, equals(999999));
        expect(product.price, equals(999999.99));
      });

      test('Product with special characters', () {
        const rating = Rating(rate: 3.5, count: 50);
        const product = Product(
          id: 1,
          title: 'Spéciâl Chäräctérs & Émojis 🎉',
          description: 'Description with ñ, ç, and other spéciâl chars',
          price: 29.99,
          image: 'special.jpg',
          category: 'spéciâl',
          rating: rating,
        );

        expect(product.title, contains('🎉'));
        expect(product.description, contains('ñ'));
        expect(product.category, equals('spéciâl'));
      });

      test('Product copyWith all parameters', () {
        const originalRating = Rating(rate: 4.0, count: 100);
        const original = Product(
          id: 1,
          title: 'Original',
          description: 'Original desc',
          price: 10.0,
          image: 'original.jpg',
          category: 'original',
          rating: originalRating,
        );

        const newRating = Rating(rate: 5.0, count: 200);
        final copied = original.copyWith(
          id: 2,
          title: 'Copied',
          description: 'Copied desc',
          price: 20.0,
          image: 'copied.jpg',
          category: 'copied',
          rating: newRating,
        );

        expect(copied.id, equals(2));
        expect(copied.title, equals('Copied'));
        expect(copied.description, equals('Copied desc'));
        expect(copied.price, equals(20.0));
        expect(copied.image, equals('copied.jpg'));
        expect(copied.category, equals('copied'));
        expect(copied.rating.rate, equals(5.0));
        expect(copied.rating.count, equals(200));
      });

      test('Product copyWith partial parameters', () {
        const rating = Rating(rate: 4.0, count: 100);
        const original = Product(
          id: 1,
          title: 'Original',
          description: 'Original desc',
          price: 10.0,
          image: 'original.jpg',
          category: 'original',
          rating: rating,
        );

        final copied = original.copyWith(title: 'New Title', price: 15.0);

        expect(copied.id, equals(1)); // unchanged
        expect(copied.title, equals('New Title')); // changed
        expect(copied.description, equals('Original desc')); // unchanged
        expect(copied.price, equals(15.0)); // changed
        expect(copied.image, equals('original.jpg')); // unchanged
        expect(copied.category, equals('original')); // unchanged
        expect(copied.rating, equals(rating)); // unchanged
      });

      test('Product equality comparison', () {
        const rating1 = Rating(rate: 4.0, count: 100);
        const rating2 = Rating(rate: 4.0, count: 100);

        const product1 = Product(
          id: 1,
          title: 'Test',
          description: 'Test desc',
          price: 10.0,
          image: 'test.jpg',
          category: 'test',
          rating: rating1,
        );

        const product2 = Product(
          id: 1,
          title: 'Test',
          description: 'Test desc',
          price: 10.0,
          image: 'test.jpg',
          category: 'test',
          rating: rating2,
        );

        expect(product1, equals(product2));
        expect(product1.hashCode, equals(product2.hashCode));
      });
    });

    group('Rating Edge Cases', () {
      test('Rating with decimal precision', () {
        const rating = Rating(rate: 4.123456789, count: 123);

        expect(rating.rate, equals(4.123456789));
        expect(rating.count, equals(123));
      });

      test('Rating equality and hashCode', () {
        const rating1 = Rating(rate: 4.5, count: 100);
        const rating2 = Rating(rate: 4.5, count: 100);
        const rating3 = Rating(rate: 4.5, count: 101);

        expect(rating1, equals(rating2));
        expect(rating1.hashCode, equals(rating2.hashCode));
        expect(rating1, isNot(equals(rating3)));
      });

      test('Rating extreme values', () {
        const minRating = Rating(rate: 0.0, count: 0);
        const maxRating = Rating(rate: 5.0, count: 999999999);

        expect(minRating.rate, equals(0.0));
        expect(minRating.count, equals(0));
        expect(maxRating.rate, equals(5.0));
        expect(maxRating.count, equals(999999999));
      });
    });

    group('CartItem Edge Cases', () {
      test('CartItem with minimum quantity', () {
        const rating = Rating(rate: 4.0, count: 100);
        const product = Product(
          id: 1,
          title: 'Test Product',
          description: 'Test',
          price: 10.0,
          image: 'test.jpg',
          category: 'test',
          rating: rating,
        );

        const cartItem = CartItem(
          id: 1,
          product: product,
          quantity: 1,
        );

        expect(cartItem.quantity, equals(1));
        expect(cartItem.totalPrice, equals(10.0));
      });

      test('CartItem with large quantity', () {
        const rating = Rating(rate: 4.0, count: 100);
        const product = Product(
          id: 1,
          title: 'Test Product',
          description: 'Test',
          price: 1.99,
          image: 'test.jpg',
          category: 'test',
          rating: rating,
        );

        const cartItem = CartItem(
          id: 1,
          product: product,
          quantity: 1000,
        );

        expect(cartItem.quantity, equals(1000));
        expect(cartItem.totalPrice, equals(1990.0));
      });

      test('CartItem with expensive product', () {
        const rating = Rating(rate: 5.0, count: 1);
        const product = Product(
          id: 1,
          title: 'Expensive Product',
          description: 'Very expensive',
          price: 9999.99,
          image: 'expensive.jpg',
          category: 'luxury',
          rating: rating,
        );

        const cartItem = CartItem(
          id: 1,
          product: product,
          quantity: 2,
        );

        expect(cartItem.totalPrice, equals(19999.98));
      });

      test('CartItem equality', () {
        const rating = Rating(rate: 4.0, count: 100);
        const product = Product(
          id: 1,
          title: 'Test',
          description: 'Test',
          price: 10.0,
          image: 'test.jpg',
          category: 'test',
          rating: rating,
        );

        const cartItem1 = CartItem(id: 1, product: product, quantity: 2);
        const cartItem2 = CartItem(id: 1, product: product, quantity: 2);
        const cartItem3 = CartItem(id: 1, product: product, quantity: 3);

        expect(cartItem1, equals(cartItem2));
        expect(cartItem1.hashCode, equals(cartItem2.hashCode));
        expect(cartItem1, isNot(equals(cartItem3)));
      });
    });

    group('Favorite Edge Cases', () {
      test('Favorite with current timestamp', () {
        final now = DateTime.now();
        final favorite = Favorite(
          id: 1,
          productId: 123,
          addedAt: now,
        );

        expect(favorite.id, equals(1));
        expect(favorite.productId, equals(123));
        expect(favorite.addedAt, equals(now));
      });

      test('Favorite with old timestamp', () {
        final oldDate = DateTime(2020, 1, 1);
        final favorite = Favorite(
          id: 1,
          productId: 456,
          addedAt: oldDate,
        );

        expect(favorite.addedAt, equals(oldDate));
        expect(favorite.addedAt.year, equals(2020));
      });

      test('Favorite with future timestamp', () {
        final futureDate = DateTime(2030, 12, 31);
        final favorite = Favorite(
          id: 1,
          productId: 789,
          addedAt: futureDate,
        );

        expect(favorite.addedAt, equals(futureDate));
        expect(favorite.addedAt.year, equals(2030));
      });

      test('Favorite equality', () {
        final date = DateTime(2023, 6, 15);
        final favorite1 = Favorite(id: 1, productId: 100, addedAt: date);
        final favorite2 = Favorite(id: 1, productId: 100, addedAt: date);
        final favorite3 = Favorite(id: 2, productId: 100, addedAt: date);

        expect(favorite1, equals(favorite2));
        expect(favorite1.hashCode, equals(favorite2.hashCode));
        expect(favorite1, equals(favorite2));
        expect(favorite1.hashCode, equals(favorite2.hashCode));
        expect(favorite1.id, isNot(equals(favorite3.id))); // Different IDs
      });

      test('Favorite with extreme IDs', () {
        final date = DateTime.now();
        final favorite = Favorite(
          id: 999999999,
          productId: 999999999,
          addedAt: date,
        );

        expect(favorite.id, equals(999999999));
        expect(favorite.productId, equals(999999999));
      });
    });

    group('Integration Edge Cases', () {
      test('CartItem with Product containing special characters', () {
        const rating = Rating(rate: 4.8, count: 50);
        const product = Product(
          id: 1,
          title: 'Café & Thé ☕🍵',
          description: 'Délicieux café français',
          price: 15.50,
          image: 'cafe.jpg',
          category: 'boissons',
          rating: rating,
        );

        const cartItem = CartItem(
          id: 1,
          product: product,
          quantity: 3,
        );

        expect(cartItem.product.title, contains('☕'));
        expect(cartItem.totalPrice, equals(46.50));
      });

      test('Product with zero rating count but positive rate', () {
        const rating = Rating(rate: 5.0, count: 0);
        const product = Product(
          id: 1,
          title: 'New Product',
          description: 'No reviews yet',
          price: 25.0,
          image: 'new.jpg',
          category: 'new',
          rating: rating,
        );

        expect(product.rating.rate, equals(5.0));
        expect(product.rating.count, equals(0));
      });

      test('Multiple entities with same IDs', () {
        final date1 = DateTime(2023, 1, 1);
        final date2 = DateTime(2023, 1, 2);

        final favorite1 = Favorite(id: 1, productId: 100, addedAt: date1);
        final favorite2 = Favorite(id: 1, productId: 100, addedAt: date2);

        // Same ID but different dates - still equal because only id, productId matter for equality
        expect(favorite1.id, equals(favorite2.id));
        expect(favorite1.productId, equals(favorite2.productId));
      });
    });

    group('Performance Edge Cases', () {
      test('Large collection operations', () {
        const rating = Rating(rate: 4.0, count: 100);
        final products = List.generate(
            1000,
            (index) => Product(
                  id: index,
                  title: 'Product $index',
                  description: 'Description $index',
                  price: index * 1.0,
                  image: 'product$index.jpg',
                  category: 'category${index % 10}',
                  rating: rating,
                ));

        expect(products.length, equals(1000));
        expect(products.first.id, equals(0));
        expect(products.last.id, equals(999));
      });

      test('Large CartItem calculations', () {
        const rating = Rating(rate: 4.0, count: 100);
        const product = Product(
          id: 1,
          title: 'Bulk Product',
          description: 'For bulk orders',
          price: 0.01,
          image: 'bulk.jpg',
          category: 'bulk',
          rating: rating,
        );

        const cartItem = CartItem(
          id: 1,
          product: product,
          quantity: 100000,
        );

        expect(cartItem.totalPrice, equals(1000.0));
      });
    });
  });
}
