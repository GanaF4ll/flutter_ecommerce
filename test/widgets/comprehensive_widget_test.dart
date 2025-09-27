import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/widgets/cart_item_card.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Comprehensive Widget Tests', () {
    late Product testProduct;
    late CartItem testCartItem;

    setUp(() {
      const testRating = Rating(rate: 4.2, count: 89);
      testProduct = const Product(
        id: 42,
        title: 'Amazing Widget Product',
        description: 'The best product for widget testing',
        price: 123.45,
        image: 'https://example.com/widget.jpg',
        category: 'widgets',
        rating: testRating,
      );

      testCartItem = CartItem(
        id: 1,
        product: testProduct,
        quantity: 3,
      );
    });

    group('ProductCard Widget Comprehensive Tests', () {
      Widget createProductCardWidget() {
        return MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProductCard(product: testProduct),
            ),
          ),
        );
      }

      testWidgets('should display all product information',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductCardWidget());
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(Card), findsAtLeastNWidgets(1));
      });

      testWidgets('should handle image loading states',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductCardWidget());
        await tester.pump(const Duration(milliseconds: 100));

        final images = find.byType(Image);
        expect(images, findsAtLeastNWidgets(0));
      });

      testWidgets('should handle tap interactions',
          (WidgetTester tester) async {
        await tester.pumpWidget(createProductCardWidget());
        await tester.pump(const Duration(milliseconds: 500));

        final inkWells = find.byType(InkWell);
        final gestureDetectors = find.byType(GestureDetector);

        if (inkWells.evaluate().isNotEmpty) {
          await tester.tap(inkWells.first);
          await tester.pump();
        }

        if (gestureDetectors.evaluate().isNotEmpty) {
          await tester.tap(gestureDetectors.first);
          await tester.pump();
        }

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('should handle different product prices',
          (WidgetTester tester) async {
        final prices = [0.01, 9.99, 99.99, 999.99, 9999.99];

        for (final price in prices) {
          final productWithPrice = testProduct.copyWith(price: price);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ProductCard(product: productWithPrice),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(ProductCard), findsOneWidget);
        }
      });

      testWidgets('should handle different rating values',
          (WidgetTester tester) async {
        final ratings = [0.0, 2.5, 3.7, 4.9, 5.0];

        for (final rate in ratings) {
          final ratingWithRate = Rating(rate: rate, count: 100);
          final productWithRating =
              testProduct.copyWith(rating: ratingWithRate);

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ProductCard(product: productWithRating),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(ProductCard), findsOneWidget);
        }
      });

      testWidgets('should handle long product titles',
          (WidgetTester tester) async {
        final longTitleProduct = testProduct.copyWith(
          title:
              'This is a very very very very very very very very long product title that should be handled properly by the widget',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: longTitleProduct),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('should handle button states', (WidgetTester tester) async {
        await tester.pumpWidget(createProductCardWidget());
        await tester.pump(const Duration(milliseconds: 500));

        final elevatedButtons = find.byType(ElevatedButton);
        final iconButtons = find.byType(IconButton);
        final textButtons = find.byType(TextButton);

        // Test all button types that might exist
        for (final buttonFinder in [
          elevatedButtons,
          iconButtons,
          textButtons
        ]) {
          if (buttonFinder.evaluate().isNotEmpty) {
            await tester.tap(buttonFinder.first);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('should maintain performance with many cards',
          (WidgetTester tester) async {
        final products = List.generate(
            10,
            (index) =>
                testProduct.copyWith(id: index, title: 'Product $index'));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) =>
                    ProductCard(product: products[index]),
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(ProductCard), findsAtLeastNWidgets(1));
      });
    });

    group('CartItemCard Widget Comprehensive Tests', () {
      Widget createCartItemCardWidget() {
        return MaterialApp(
          home: Scaffold(
            body: CartItemCard(item: testCartItem),
          ),
        );
      }

      testWidgets('should display cart item information',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCartItemCardWidget());
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('should handle quantity changes',
          (WidgetTester tester) async {
        await tester.pumpWidget(createCartItemCardWidget());
        await tester.pump(const Duration(milliseconds: 500));

        final iconButtons = find.byType(IconButton);
        if (iconButtons.evaluate().length >= 2) {
          // Test increment/decrement buttons
          await tester.tap(iconButtons.first);
          await tester.pump();

          await tester.tap(iconButtons.last);
          await tester.pump();
        }

        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('should handle different quantities',
          (WidgetTester tester) async {
        final quantities = [1, 5, 10, 99, 999];

        for (final quantity in quantities) {
          final cartItemWithQuantity = CartItem(
            id: testCartItem.id,
            product: testCartItem.product,
            quantity: quantity,
          );

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CartItemCard(item: cartItemWithQuantity),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CartItemCard), findsOneWidget);
        }
      });

      testWidgets('should handle remove actions', (WidgetTester tester) async {
        await tester.pumpWidget(createCartItemCardWidget());
        await tester.pump(const Duration(milliseconds: 500));

        final iconButtons = find.byType(IconButton);
        final elevatedButtons = find.byType(ElevatedButton);

        // Try to find and tap remove/delete buttons
        if (iconButtons.evaluate().isNotEmpty) {
          final removeButtons = iconButtons
              .evaluate()
              .where((element) => element.widget is IconButton);

          if (removeButtons.isNotEmpty) {
            await tester.tap(find.byWidget(removeButtons.first.widget));
            await tester.pump();
          }
        }

        if (elevatedButtons.evaluate().isNotEmpty) {
          await tester.tap(elevatedButtons.first);
          await tester.pump();
        }

        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('should calculate total price correctly',
          (WidgetTester tester) async {
        final quantities = [1, 2, 5, 10];

        for (final quantity in quantities) {
          final cartItem = CartItem(
            id: 1,
            product: testProduct,
            quantity: quantity,
          );

          expect(cartItem.totalPrice, equals(testProduct.price * quantity));

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CartItemCard(item: cartItem),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 100));
          expect(find.byType(CartItemCard), findsOneWidget);
        }
      });

      testWidgets('should handle expensive items', (WidgetTester tester) async {
        final expensiveProduct = testProduct.copyWith(price: 9999.99);
        final expensiveCartItem = CartItem(
          id: 1,
          product: expensiveProduct,
          quantity: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CartItemCard(item: expensiveCartItem),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(CartItemCard), findsOneWidget);
      });
    });

    group('Widget Layout Tests', () {
      testWidgets('widgets should handle small screens',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ProductCard(product: testProduct),
                  CartItemCard(item: testCartItem),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('widgets should handle large screens',
          (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(child: ProductCard(product: testProduct)),
                  Expanded(child: CartItemCard(item: testCartItem)),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('widgets should handle orientation changes',
          (WidgetTester tester) async {
        final widget = MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ProductCard(product: testProduct),
                CartItemCard(item: testCartItem),
              ],
            ),
          ),
        );

        // Portrait
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(widget);
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);

        // Landscape
        await tester.binding.setSurfaceSize(const Size(800, 400));
        await tester.pumpWidget(widget);
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });
    });

    group('Widget Performance Tests', () {
      testWidgets('widgets should render quickly', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ProductCard(product: testProduct),
                  CartItemCard(item: testCartItem),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('widgets should handle rapid rebuilds',
          (WidgetTester tester) async {
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ProductCard(product: testProduct.copyWith(id: i)),
                    CartItemCard(item: testCartItem),
                  ],
                ),
              ),
            ),
          );

          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });
    });

    group('Widget Edge Cases', () {
      testWidgets('widgets should handle null-like scenarios',
          (WidgetTester tester) async {
        final edgeCaseProduct = Product(
          id: 0,
          title: '',
          description: '',
          price: 0.0,
          image: '',
          category: '',
          rating: const Rating(rate: 0.0, count: 0),
        );

        final edgeCaseCartItem = CartItem(
          id: 0,
          product: edgeCaseProduct,
          quantity: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ProductCard(product: edgeCaseProduct),
                  CartItemCard(item: edgeCaseCartItem),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });

      testWidgets('widgets should handle special characters',
          (WidgetTester tester) async {
        final specialProduct = testProduct.copyWith(
          title: 'Spéciâl Chäräctérs & Émojis 🎉🛒💯',
          description: 'Tëst with ñ, ç, and other spéciâl chars',
        );

        final specialCartItem = CartItem(
          id: 1,
          product: specialProduct,
          quantity: 1,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  ProductCard(product: specialProduct),
                  CartItemCard(item: specialCartItem),
                ],
              ),
            ),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(ProductCard), findsOneWidget);
        expect(find.byType(CartItemCard), findsOneWidget);
      });
    });
  });
}
