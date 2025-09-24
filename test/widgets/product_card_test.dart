import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard Widget Tests', () {
    late Product testProduct;

    setUp(() {
      const testRating = Rating(rate: 4.5, count: 100);
      testProduct = const Product(
        id: 1,
        title: 'Test Product with Long Title',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: testRating,
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(body: ProductCard(product: testProduct)),
      );
    }

    testWidgets('should display product information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifier que le titre du produit est affiché
      expect(find.text('Test Product with Long Title'), findsOneWidget);

      // Vérifier que le prix est affiché
      expect(find.text('\$99.99'), findsOneWidget);

      // Vérifier que la carte est présente
      expect(find.byType(Card), findsOneWidget);

      // Vérifier que l'image est présente
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should display favorite button', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifier que le bouton favoris est présent
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should display add to cart button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifier que le bouton d'ajout au panier est présent
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display LOW STOCK badge when rating count is low', (
      WidgetTester tester,
    ) async {
      const lowStockRating = Rating(rate: 4.5, count: 30); // < 50
      final lowStockProduct = Product(
        id: 1,
        title: 'Low Stock Product',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: lowStockRating,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductCard(product: lowStockProduct)),
        ),
      );

      // Vérifier que le badge LOW STOCK est affiché
      expect(find.text('LOW STOCK'), findsOneWidget);
    });

    testWidgets(
      'should not display LOW STOCK badge when rating count is high',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Vérifier que le badge LOW STOCK n'est pas affiché
        expect(find.text('LOW STOCK'), findsNothing);
      },
    );

    testWidgets('should handle image loading error gracefully', (
      WidgetTester tester,
    ) async {
      final productWithBadImage = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'invalid-url',
        category: 'electronics',
        rating: const Rating(rate: 4.5, count: 100),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductCard(product: productWithBadImage)),
        ),
      );

      await tester.pump();

      // Vérifier que l'icône d'erreur est affichée
      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('should be tappable and navigate to product page', (
      WidgetTester tester,
    ) async {
      bool navigationCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductCard(product: testProduct)),
          onGenerateRoute: (settings) {
            if (settings.name == '/product/1') {
              navigationCalled = true;
            }
            return MaterialPageRoute(
              builder: (context) => const Scaffold(body: Text('Product Page')),
            );
          },
        ),
      );

      // Taper sur la carte
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Vérifier que la navigation a été appelée
      expect(navigationCalled, isTrue);
    });

    testWidgets('should display correct text styles', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifier les styles de texte
      final titleText = tester.widget<Text>(
        find.text('Test Product with Long Title'),
      );
      expect(titleText.style?.fontSize, 12);
      expect(titleText.style?.fontWeight, FontWeight.w500);

      final priceText = tester.widget<Text>(find.text('\$99.99'));
      expect(priceText.style?.fontSize, 14);
      expect(priceText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('should truncate long titles correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final titleText = tester.widget<Text>(
        find.text('Test Product with Long Title'),
      );
      expect(titleText.maxLines, 2);
      expect(titleText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should display proper aspect ratio for image', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, 1.0);
    });
  });
}
