import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/cart_page.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_ecommerce/pages/favorites_page.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
import 'package:flutter_ecommerce/pages/login_page.dart';
import 'package:flutter_ecommerce/pages/product_page.dart';
import 'package:flutter_ecommerce/pages/register_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Page Creation Tests', () {
    testWidgets('CartPage should be creatable', (WidgetTester tester) async {
      const widget = CartPage();
      expect(widget, isA<CartPage>());
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('CatalogPage should be creatable', (WidgetTester tester) async {
      const widget = CatalogPage();
      expect(widget, isA<CatalogPage>());
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('FavoritesPage should be creatable',
        (WidgetTester tester) async {
      const widget = FavoritesPage();
      expect(widget, isA<FavoritesPage>());
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('HomePage should be creatable', (WidgetTester tester) async {
      const widget = HomePage();
      expect(widget, isA<HomePage>());
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('LoginPage should be creatable', (WidgetTester tester) async {
      const widget = LoginPage();
      expect(widget, isA<LoginPage>());
      expect(widget, isA<StatefulWidget>());
    });

    testWidgets('ProductPage should be creatable', (WidgetTester tester) async {
      const widget = ProductPage(id: '1');
      expect(widget, isA<ProductPage>());
      expect(widget, isA<StatefulWidget>());
      expect(widget.id, '1');
    });

    testWidgets('RegisterPage should be creatable',
        (WidgetTester tester) async {
      const widget = RegisterPage();
      expect(widget, isA<RegisterPage>());
      expect(widget, isA<StatefulWidget>());
    });

    group('ProductPage properties', () {
      testWidgets('should store id correctly', (WidgetTester tester) async {
        const widget = ProductPage(id: 'test-id-123');
        expect(widget.id, 'test-id-123');
      });

      testWidgets('should handle different id types',
          (WidgetTester tester) async {
        const widget1 = ProductPage(id: '1');
        const widget2 = ProductPage(id: 'abc');
        const widget3 = ProductPage(id: '99999');

        expect(widget1.id, '1');
        expect(widget2.id, 'abc');
        expect(widget3.id, '99999');
      });

      testWidgets('should handle empty id', (WidgetTester tester) async {
        const widget = ProductPage(id: '');
        expect(widget.id, '');
      });
    });

    group('Page Widget Types', () {
      test('all pages should be widgets', () {
        expect(const CartPage(), isA<Widget>());
        expect(const CatalogPage(), isA<Widget>());
        expect(const FavoritesPage(), isA<Widget>());
        expect(const HomePage(), isA<Widget>());
        expect(const LoginPage(), isA<Widget>());
        expect(const ProductPage(id: '1'), isA<Widget>());
        expect(const RegisterPage(), isA<Widget>());
      });

      test('all pages should be stateful widgets', () {
        expect(const CartPage(), isA<StatefulWidget>());
        expect(const CatalogPage(), isA<StatefulWidget>());
        expect(const FavoritesPage(), isA<StatefulWidget>());
        expect(const HomePage(), isA<StatefulWidget>());
        expect(const LoginPage(), isA<StatefulWidget>());
        expect(const ProductPage(id: '1'), isA<StatefulWidget>());
        expect(const RegisterPage(), isA<StatefulWidget>());
      });
    });

    group('Page State Creation', () {
      testWidgets('pages should create state objects',
          (WidgetTester tester) async {
        const cartPage = CartPage();
        const catalogPage = CatalogPage();
        const favoritesPage = FavoritesPage();
        const homePage = HomePage();
        const loginPage = LoginPage();
        const productPage = ProductPage(id: '1');
        const registerPage = RegisterPage();

        expect(cartPage.createState(), isA<State>());
        expect(catalogPage.createState(), isA<State>());
        expect(favoritesPage.createState(), isA<State>());
        expect(homePage.createState(), isA<State>());
        expect(loginPage.createState(), isA<State>());
        expect(productPage.createState(), isA<State>());
        expect(registerPage.createState(), isA<State>());
      });
    });

    group('Page Construction Edge Cases', () {
      testWidgets('ProductPage with very long productId',
          (WidgetTester tester) async {
        const longId =
            'very-very-very-very-very-very-long-product-id-123456789';
        const widget = ProductPage(id: longId);
        expect(widget.id, longId);
      });

      testWidgets('ProductPage with special characters',
          (WidgetTester tester) async {
        const specialId = 'product-id-with-special-chars-!@#\$%^&*()';
        const widget = ProductPage(id: specialId);
        expect(widget.id, specialId);
      });

      testWidgets('ProductPage with numeric string',
          (WidgetTester tester) async {
        const numericId = '1234567890';
        const widget = ProductPage(id: numericId);
        expect(widget.id, numericId);
      });
    });

    group('Multiple Page Instances', () {
      testWidgets('should create multiple instances correctly',
          (WidgetTester tester) async {
        const page1 = ProductPage(id: '1');
        const page2 = ProductPage(id: '2');
        const page3 = ProductPage(id: '3');

        expect(page1.id, '1');
        expect(page2.id, '2');
        expect(page3.id, '3');

        expect(page1, isNot(same(page2)));
        expect(page2, isNot(same(page3)));
        expect(page1, isNot(same(page3)));
      });

      testWidgets('should create multiple cart pages',
          (WidgetTester tester) async {
        const cart1 = CartPage();
        const cart2 = CartPage();

        expect(cart1, isA<CartPage>());
        expect(cart2, isA<CartPage>());
        expect(cart1, isNot(same(cart2)));
      });
    });

    group('Page Equality', () {
      testWidgets('ProductPage equality based on productId',
          (WidgetTester tester) async {
        const page1 = ProductPage(id: 'same-id');
        const page2 = ProductPage(id: 'same-id');
        const page3 = ProductPage(id: 'different-id');

        // Note: Ces tests vérifient la structure, pas l'égalité d'objets
        expect(page1.id, page2.id);
        expect(page1.id, isNot(page3.id));
      });
    });

    group('Page Key Properties', () {
      testWidgets('pages should accept key parameter',
          (WidgetTester tester) async {
        const key1 = Key('cart-key');
        const key2 = Key('catalog-key');
        const key3 = Key('product-key');

        const cartPage = CartPage(key: key1);
        const catalogPage = CatalogPage(key: key2);
        const productPage = ProductPage(key: key3, id: '1');

        expect(cartPage.key, key1);
        expect(catalogPage.key, key2);
        expect(productPage.key, key3);
      });
    });
  });
}
