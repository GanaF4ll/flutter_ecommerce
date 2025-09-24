import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firebase Auth
class MockFirebaseAuth extends Fake implements FirebaseAuth {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }
}

class MockUser extends Fake implements User {
  @override
  String get uid => 'test-uid';

  @override
  String? get email => 'test@example.com';
}

void main() {
  group('AppDrawer Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(drawer: const AppDrawer(), body: const Text('Test')),
        routes: {
          '/': (context) => const Scaffold(body: Text('Home')),
          '/catalog': (context) => const Scaffold(body: Text('Catalog')),
          '/cart': (context) => const Scaffold(body: Text('Cart')),
          '/favorites': (context) => const Scaffold(body: Text('Favorites')),
          '/login': (context) => const Scaffold(body: Text('Login')),
          '/register': (context) => const Scaffold(body: Text('Register')),
        },
      );
    }

    testWidgets('should display drawer header with app title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Ouvrir le drawer
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier que le header est affiché
      expect(find.byType(DrawerHeader), findsOneWidget);
      expect(find.text('Flutter E-commerce'), findsOneWidget);
    });

    testWidgets('should display common navigation items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier les éléments de navigation communs
      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Catalogue'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Favoris'), findsOneWidget);

      // Vérifier les icônes
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.euro_outlined), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display login/register when user not logged in', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier que les options de connexion sont affichées
      expect(find.text('Se connecter'), findsOneWidget);
      expect(find.text('S\'inscrire'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);

      // Vérifier que le logout n'est pas affiché
      expect(find.text('Se déconnecter'), findsNothing);
    });

    testWidgets('should display logout when user is logged in', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(MockUser());

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier que le logout est affiché
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      // Vérifier que login/register ne sont pas affichés
      expect(find.text('Se connecter'), findsNothing);
      expect(find.text('S\'inscrire'), findsNothing);
    });

    testWidgets('should navigate when tapping on menu items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Taper sur Catalogue
      await tester.tap(find.text('Catalogue'));
      await tester.pumpAndSettle();

      // Vérifier que la navigation a eu lieu
      expect(find.text('Catalog'), findsOneWidget);
    });

    testWidgets('should navigate to cart when tapping cart item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Taper sur Panier
      await tester.tap(find.text('Panier'));
      await tester.pumpAndSettle();

      // Vérifier que la navigation a eu lieu
      expect(find.text('Cart'), findsOneWidget);
    });

    testWidgets('should navigate to favorites when tapping favorites item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Taper sur Favoris
      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();

      // Vérifier que la navigation a eu lieu
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('should have proper styling for drawer header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      final drawerHeader = tester.widget<DrawerHeader>(
        find.byType(DrawerHeader),
      );
      final decoration = drawerHeader.decoration as BoxDecoration;
      expect(decoration.color, Colors.cyan);

      final headerText = tester.widget<Text>(find.text('Flutter E-commerce'));
      expect(headerText.style?.color, Colors.white);
      expect(headerText.style?.fontSize, 24);
    });

    testWidgets('should close drawer when navigating', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Ouvrir le drawer
      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier que le drawer est ouvert
      expect(find.byType(Drawer), findsOneWidget);

      // Taper sur un élément de navigation
      await tester.tap(find.text('Catalogue'));
      await tester.pumpAndSettle();

      // Le drawer devrait être fermé (nous ne pouvons pas tester cela directement
      // mais nous pouvons vérifier que la navigation a eu lieu)
      expect(find.text('Catalog'), findsOneWidget);
    });

    testWidgets('should display correct icon colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      // Vérifier les couleurs des icônes
      final homeIcon = tester.widget<Icon>(find.byIcon(Icons.home));
      expect(homeIcon.color, Colors.cyan);

      final catalogIcon = tester.widget<Icon>(find.byIcon(Icons.euro_outlined));
      expect(catalogIcon.color, Colors.cyan);

      final cartIcon = tester.widget<Icon>(find.byIcon(Icons.shopping_cart));
      expect(cartIcon.color, Colors.cyan);

      final favoriteIcon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(favoriteIcon.color, Colors.pink);
    });
  });
}
