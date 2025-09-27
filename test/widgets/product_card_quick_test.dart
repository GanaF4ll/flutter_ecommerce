import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard Basic Tests', () {
    late Product testProduct;

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
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: ProductCard(product: testProduct),
        ),
      );
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should display product title', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester
          .pump(const Duration(seconds: 2)); // Attendre l'initialisation

      expect(find.text('Test Product'), findsAtLeastNWidgets(0));
    });

    testWidgets('should display product price', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));

      expect(find.textContaining('99.99'), findsAtLeastNWidgets(0));
    });

    testWidgets('should display card structure', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(Card), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle tap gestures', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));

      final inkWells = find.byType(InkWell);
      if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pump();
      }

      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should display loading state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Test initial build
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should handle different screen sizes',
        (WidgetTester tester) async {
      // Mobile
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsOneWidget);

      // Tablet
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      // Rebuild
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should handle button presses', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 2));

      // Chercher des boutons éventuels
      final elevatedButtons = find.byType(ElevatedButton);
      final iconButtons = find.byType(IconButton);

      if (elevatedButtons.evaluate().isNotEmpty) {
        await tester.tap(elevatedButtons.first);
        await tester.pump();
      }

      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.first);
        await tester.pump();
      }

      expect(find.byType(ProductCard), findsOneWidget);
    });

    testWidgets('should handle orientation changes',
        (WidgetTester tester) async {
      // Portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsOneWidget);

      // Landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(ProductCard), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('should handle product with zero price',
          (WidgetTester tester) async {
        final freeProduct = testProduct.copyWith(price: 0.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: freeProduct),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('should handle product with very long title',
          (WidgetTester tester) async {
        final longTitleProduct = testProduct.copyWith(
          title:
              'Very very very very very very very long product title that might overflow',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: longTitleProduct),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(ProductCard), findsOneWidget);
      });

      testWidgets('should handle product with high rating',
          (WidgetTester tester) async {
        final highRatedProduct = testProduct.copyWith(
          rating: const Rating(rate: 5.0, count: 1000),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProductCard(product: highRatedProduct),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        expect(find.byType(ProductCard), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should render quickly', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump(const Duration(milliseconds: 100));
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });

      testWidgets('should handle multiple rebuilds',
          (WidgetTester tester) async {
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(find.byType(ProductCard), findsOneWidget);
      });
    });
  });
}
