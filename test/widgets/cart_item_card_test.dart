import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/widgets/cart_item_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartItemCard Widget Tests', () {
    late CartItem testCartItem;
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

      testCartItem = CartItem(
        id: 1,
        product: testProduct,
        quantity: 2,
      );
    });

    Widget createWidgetUnderTest({
      required CartItem cartItem,
      Function(int)? onUpdateQuantity,
      VoidCallback? onRemove,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CartItemCard(
            item: cartItem,
            onUpdateQuantity: onUpdateQuantity ?? (quantity) {},
            onRemove: onRemove ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display cart item information correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(cartItem: testCartItem));

      // Vérifier que les informations du produit sont affichées
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.textContaining('99.99'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Quantité

      // Vérifier que l'image est présente
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should calculate total price correctly',
        (WidgetTester tester) async {
      // Tester la logique du calcul du prix total
      expect(testCartItem.totalPrice, equals(199.98));
    });

    testWidgets('should display correct layout', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(cartItem: testCartItem));

      // Vérifier la présence des éléments de base
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should handle cart item with quantity 1',
        (WidgetTester tester) async {
      final singleQuantityProduct = const Product(
        id: 2,
        title: 'Single Item',
        description: 'Description',
        price: 50.0,
        image: 'https://example.com/image2.jpg',
        category: 'books',
        rating: Rating(rate: 3.5, count: 10),
      );

      final singleQuantityItem = CartItem(
        id: 2,
        product: singleQuantityProduct,
        quantity: 1,
      );

      await tester
          .pumpWidget(createWidgetUnderTest(cartItem: singleQuantityItem));

      expect(find.text('Single Item'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.textContaining('50.0'), findsOneWidget);
    });

    testWidgets('should handle cart item with high quantity',
        (WidgetTester tester) async {
      final bulkProduct = const Product(
        id: 3,
        title: 'Bulk Item',
        description: 'Description',
        price: 10.0,
        image: 'https://example.com/image3.jpg',
        category: 'supplies',
        rating: Rating(rate: 4.0, count: 200),
      );

      final highQuantityItem = CartItem(
        id: 3,
        product: bulkProduct,
        quantity: 25,
      );

      await tester
          .pumpWidget(createWidgetUnderTest(cartItem: highQuantityItem));

      expect(find.text('Bulk Item'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      // Vérifier le calcul du prix total
      expect(highQuantityItem.totalPrice, equals(250.0));
    });

    testWidgets('should handle long product titles',
        (WidgetTester tester) async {
      const longTitleProduct = Product(
        id: 4,
        title:
            'This is a very long product title that should be handled gracefully by the UI component',
        description: 'Description',
        price: 75.99,
        image: 'https://example.com/image4.jpg',
        category: 'electronics',
        rating: Rating(rate: 3.8, count: 45),
      );

      final longTitleItem = CartItem(
        id: 4,
        product: longTitleProduct,
        quantity: 3,
      );

      await tester.pumpWidget(createWidgetUnderTest(cartItem: longTitleItem));

      // Vérifier que le widget ne plante pas avec un titre long
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.textContaining('This is a very long'), findsOneWidget);
    });

    testWidgets('should handle image loading error',
        (WidgetTester tester) async {
      const badImageProduct = Product(
        id: 5,
        title: 'Product with bad image',
        description: 'Description',
        price: 25.0,
        image: 'invalid-url',
        category: 'misc',
        rating: Rating(rate: 2.5, count: 5),
      );

      final itemWithBadImage = CartItem(
        id: 5,
        product: badImageProduct,
        quantity: 1,
      );

      await tester
          .pumpWidget(createWidgetUnderTest(cartItem: itemWithBadImage));

      // Vérifier que le widget gère gracieusement les erreurs d'image
      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.text('Product with bad image'), findsOneWidget);
    });

    testWidgets(
        'should calculate total price correctly for different quantities',
        (WidgetTester tester) async {
      final item = CartItem(
        id: 6,
        product: testProduct,
        quantity: 3,
      );

      expect(item.totalPrice, equals(299.97)); // 99.99 * 3
    });

    testWidgets('should handle zero quantity', (WidgetTester tester) async {
      final zeroQuantityItem = CartItem(
        id: 7,
        product: testProduct,
        quantity: 0,
      );

      await tester
          .pumpWidget(createWidgetUnderTest(cartItem: zeroQuantityItem));

      expect(find.byType(CartItemCard), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(zeroQuantityItem.totalPrice, equals(0.0));
    });
  });
}
