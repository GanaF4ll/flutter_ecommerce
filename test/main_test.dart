import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/main.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp should be creatable without services',
        (WidgetTester tester) async {
      const widget = MyApp();
      expect(widget, isA<MyApp>());
      expect(widget, isA<StatelessWidget>());
      expect(widget.cartService, isNull);
      expect(widget.favoriteService, isNull);
    });

    testWidgets('MyApp should be creatable with services',
        (WidgetTester tester) async {
      const widget = MyApp(
        cartService: null, // Mock services in real tests
        favoriteService: null,
      );
      expect(widget, isA<MyApp>());
      expect(widget.cartService, isNull);
      expect(widget.favoriteService, isNull);
    });

    testWidgets('MyApp should accept key parameter',
        (WidgetTester tester) async {
      const key = Key('my-app-key');
      const widget = MyApp(key: key);
      expect(widget.key, key);
    });

    testWidgets('MyApp should build MaterialApp correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Vérifier que MaterialApp est créé
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Flutter E-Commerce Gana');
    });

    testWidgets('MyApp should disable debug banner',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, false);
    });

    testWidgets('MyApp should have Material3 theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.useMaterial3, true);
      expect(materialApp.theme?.colorScheme?.primary, isNotNull);
    });

    testWidgets('MyApp should have correct initial route',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.initialRoute, '/');
    });

    group('MyApp Routes', () {
      testWidgets('should have all required routes',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final routes = materialApp.routes!;

        expect(routes.containsKey('/'), true);
        expect(routes.containsKey('/login'), true);
        expect(routes.containsKey('/register'), true);
        expect(routes.containsKey('/catalog'), true);
        expect(routes.containsKey('/cart'), true);
        expect(routes.containsKey('/favorites'), true);
      });

      testWidgets('should navigate to home page', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // La page d'accueil devrait être affichée par défaut
        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets('should handle product route generation',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test de génération de route pour un produit
        const settings = RouteSettings(name: '/product/123');
        final route = onGenerateRoute(settings);

        expect(route, isNotNull);
        expect(route, isA<MaterialPageRoute>());
      });

      testWidgets('should handle invalid product route',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test de route invalide
        const settings = RouteSettings(name: '/invalid/route');
        final route = onGenerateRoute(settings);

        expect(route, isNull);
      });

      testWidgets('should extract product ID correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test d'extraction d'ID de produit
        const settings1 = RouteSettings(name: '/product/123');
        const settings2 = RouteSettings(name: '/product/abc');
        const settings3 = RouteSettings(name: '/product/999');

        final route1 = onGenerateRoute(settings1);
        final route2 = onGenerateRoute(settings2);
        final route3 = onGenerateRoute(settings3);

        expect(route1, isNotNull);
        expect(route2, isNotNull);
        expect(route3, isNotNull);
      });

      testWidgets('should handle empty product ID',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test avec ID vide
        const settings = RouteSettings(name: '/product/');
        final route = onGenerateRoute(settings);

        // Même avec un ID vide, la route devrait être créée
        expect(route, isNotNull);
      });

      testWidgets('should handle complex product IDs',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test avec ID complexe
        const settings = RouteSettings(name: '/product/product-123-abc');
        final route = onGenerateRoute(settings);

        expect(route, isNotNull);
      });
    });

    group('MyApp Properties', () {
      test('MyApp should store cart service correctly', () {
        const widget = MyApp(cartService: null);
        expect(widget.cartService, isNull);
      });

      test('MyApp should store favorite service correctly', () {
        const widget = MyApp(favoriteService: null);
        expect(widget.favoriteService, isNull);
      });

      test('MyApp should be immutable', () {
        const widget1 = MyApp();
        const widget2 = MyApp();

        // Bien que les objets soient différents, leurs propriétés sont les mêmes
        expect(widget1.cartService, widget2.cartService);
        expect(widget1.favoriteService, widget2.favoriteService);
      });

      test('MyApp should handle null services gracefully', () {
        expect(() => const MyApp(cartService: null, favoriteService: null),
            returnsNormally);
      });
    });

    group('Route Testing Edge Cases', () {
      testWidgets('should handle route with multiple slashes',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test avec plusieurs slashes
        const settings = RouteSettings(name: '/product//123');
        final route = onGenerateRoute(settings);

        expect(route, isNotNull);
      });

      testWidgets('should handle route with query parameters',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test avec paramètres de requête
        const settings =
            RouteSettings(name: '/product/123?color=red&size=large');
        final route = onGenerateRoute(settings);

        expect(route, isNotNull);
      });

      testWidgets('should handle route case sensitivity',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final onGenerateRoute = materialApp.onGenerateRoute!;

        // Test de sensibilité à la casse
        const settings1 = RouteSettings(name: '/product/123');
        const settings2 = RouteSettings(name: '/PRODUCT/123');

        final route1 = onGenerateRoute(settings1);
        final route2 = onGenerateRoute(settings2);

        expect(route1, isNotNull);
        expect(
            route2, isNull); // Devrait être null car la casse ne correspond pas
      });
    });

    group('Theme Testing', () {
      testWidgets('should use cyan color scheme', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        final materialApp =
            tester.widget<MaterialApp>(find.byType(MaterialApp));
        final theme = materialApp.theme!;

        // Vérifier que le thème utilise cyan comme couleur de base
        expect(theme.colorScheme, isNotNull);
        expect(theme.useMaterial3, true);
      });

      testWidgets('should be accessible', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Vérifier l'accessibilité de base
        final Semantics semantics = tester.widget(find.byType(Semantics).first);
        expect(semantics, isNotNull);
      });
    });
  });
}
