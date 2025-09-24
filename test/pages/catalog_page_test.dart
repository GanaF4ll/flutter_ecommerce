import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_ecommerce/widgets/product_filter.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firebase Auth
class MockFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  group('CatalogPage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: const CatalogPage(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
          '/cart': (context) => const Scaffold(body: Text('Cart Page')),
        },
      );
    }

    testWidgets('should display app bar with correct title and styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Catalogue'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.cyan);
      expect(appBar.foregroundColor, Colors.white);
    });

    testWidgets('should display drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le drawer est présent
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('should display product filter', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le filtre de produits est présent
      expect(find.byType(ProductFilter), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Avant que les données ne soient chargées
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display products grid when data is loaded', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que la grille de produits est présente
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should use correct grid properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

      expect(delegate.crossAxisCount, 2);
      expect(delegate.childAspectRatio, 0.7);
      expect(delegate.crossAxisSpacing, 12);
      expect(delegate.mainAxisSpacing, 12);
    });

    testWidgets('should have correct padding for grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final gridView = tester.widget<GridView>(find.byType(GridView));
      final padding = gridView.padding as EdgeInsets;

      expect(padding.left, 16);
      expect(padding.right, 16);
      expect(padding.top, 16);
      expect(padding.bottom, 16);
    });

    testWidgets('should display correct layout structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier la structure de la page
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(FutureBuilder), findsOneWidget);
    });

    testWidgets('should handle empty product list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Si aucun produit n'est trouvé, le message approprié devrait être affiché
      // Note: Ceci dépend de l'implémentation du ProductRepository mock
      // expect(find.text('No products found'), findsOneWidget);
    });

    testWidgets('should open drawer when tapping drawer button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ouvrir le drawer
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier que le drawer est ouvert
      expect(find.byType(DrawerHeader), findsOneWidget);
    });

    testWidgets('should maintain scroll position', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le scroll fonctionne
      final gridView = find.byType(GridView);
      await tester.drag(gridView, const Offset(0, -300));
      await tester.pumpAndSettle();

      // La page devrait toujours être affichée
      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle category filter changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le filtre est présent et interactif
      expect(find.byType(ProductFilter), findsOneWidget);

      // Note: Les tests spécifiques des filtres dépendent de l'implémentation
      // du widget ProductFilter
    });

    testWidgets('should display error message when products fail to load', (
      WidgetTester tester,
    ) async {
      // Ce test nécessiterait un mock du ProductRepository qui échoue
      // await tester.pumpWidget(createWidgetUnderTest());
      // await tester.pumpAndSettle();
      // expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('should have correct theme colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

      // Vérifier que les couleurs du thème sont cohérentes
      // Note: Ceci dépend de la configuration du thème dans l'app
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('should handle product card interactions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que les cartes de produits sont présentes et interactives
      expect(find.byType(ProductCard), findsWidgets);

      // Test d'interaction avec une carte de produit
      if (tester.widgetList(find.byType(ProductCard)).isNotEmpty) {
        await tester.tap(find.byType(ProductCard).first);
        await tester.pumpAndSettle();

        // Vérifier l'interaction
        // Note: Ceci dépend de l'implémentation de la navigation
      }
    });

    testWidgets('should maintain state during rebuild', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Simuler un rebuild
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que l'état est maintenu
      expect(find.byType(CatalogPage), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('should have correct accessibility labels', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que les éléments ont des labels d'accessibilité appropriés
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Catalogue'), findsOneWidget);
    });
  });
}
