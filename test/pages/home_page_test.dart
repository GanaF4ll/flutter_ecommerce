import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
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
  group('HomePage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: const HomePage(),
        routes: {
          '/catalog': (context) => const Scaffold(body: Text('Catalog Page')),
          '/cart': (context) => const Scaffold(body: Text('Cart Page')),
          '/login': (context) => const Scaffold(body: Text('Login Page')),
        },
      );
    }

    testWidgets('should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que l'AppBar est affiché avec le bon titre
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('E-Commerce Flutter'), findsOneWidget);
    });

    testWidgets('should display drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le drawer est présent
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Avant que les données ne soient chargées
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display hero banner', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier le contenu du banner
      expect(find.text('Bienvenue dans votre'), findsOneWidget);
      expect(find.text('E-Commerce Flutter'), findsWidgets);
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
    });

    testWidgets('should display search bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que la barre de recherche est présente
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Rechercher des produits...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display categories section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier la section des catégories
      expect(find.text('Catégories populaires'), findsOneWidget);
    });

    testWidgets('should display featured products section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier la section des produits vedettes
      expect(find.text('Produits vedettes'), findsOneWidget);
      expect(find.text('Voir tout'), findsOneWidget);
    });

    testWidgets('should navigate to catalog when tapping "Voir tout"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Taper sur "Voir tout"
      await tester.tap(find.text('Voir tout'));
      await tester.pumpAndSettle();

      // Vérifier la navigation
      expect(find.text('Catalog Page'), findsOneWidget);
    });

    testWidgets('should navigate to catalog when submitting search', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Entrer du texte dans la barre de recherche
      await tester.enterText(find.byType(TextField), 'smartphone');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Vérifier la navigation
      expect(find.text('Catalog Page'), findsOneWidget);
    });

    testWidgets('should not navigate when submitting empty search', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Entrer du texte vide dans la barre de recherche
      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Vérifier qu'il n'y a pas de navigation
      expect(find.text('Catalog Page'), findsNothing);
      expect(find.text('Bienvenue dans votre'), findsOneWidget);
    });

    testWidgets('should display hero banner with correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier le container du banner
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 200);

      // Vérifier le dégradé
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors, contains(Colors.cyan));
      expect(gradient.colors, contains(Colors.blue));
    });

    testWidgets('should display search bar with correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;

      expect(decoration.hintText, 'Rechercher des produits...');
      expect(decoration.filled, true);
      expect(decoration.fillColor, Colors.grey[100]);
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

    testWidgets('should handle scroll correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le scroll fonctionne
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // La page devrait toujours être affichée
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display correct section titles with proper styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier les styles des titres de section
      final categoriesTitle = tester.widget<Text>(
        find.text('Catégories populaires'),
      );
      expect(categoriesTitle.style?.fontSize, 20);
      expect(categoriesTitle.style?.fontWeight, FontWeight.bold);

      final productsTitle = tester.widget<Text>(find.text('Produits vedettes'));
      expect(productsTitle.style?.fontSize, 20);
      expect(productsTitle.style?.fontWeight, FontWeight.bold);
    });
  });
}
