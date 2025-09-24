import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
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
  group('AuthGuard Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidgetUnderTest({String loginRoute = '/login'}) {
      return MaterialApp(
        home: AuthGuard(
          loginRoute: loginRoute,
          child: const Scaffold(body: Text('Protected Content')),
        ),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
          '/custom-login': (context) =>
              const Scaffold(body: Text('Custom Login Page')),
        },
      );
    }

    testWidgets('should display protected content when user is authenticated', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(MockUser());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le contenu protégé est affiché
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Login Page'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should redirect to login when user is not authenticated', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que l'utilisateur est redirigé vers la page de connexion
      expect(find.text('Login Page'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('should display loading indicator during redirection', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Avant pumpAndSettle, nous devrions voir l'indicateur de chargement
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
      expect(find.text('Login Page'), findsNothing);
    });

    testWidgets('should use custom login route when specified', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(
        createWidgetUnderTest(loginRoute: '/custom-login'),
      );
      await tester.pumpAndSettle();

      // Vérifier que l'utilisateur est redirigé vers la page de connexion personnalisée
      expect(find.text('Custom Login Page'), findsOneWidget);
      expect(find.text('Login Page'), findsNothing);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('should use default login route when not specified', (
      WidgetTester tester,
    ) async {
      mockAuth.setCurrentUser(null);

      // Créer AuthGuard sans spécifier loginRoute
      await tester.pumpWidget(
        MaterialApp(
          home: const AuthGuard(
            child: Scaffold(body: Text('Protected Content')),
          ),
          routes: {
            '/login': (context) =>
                const Scaffold(body: Text('Default Login Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier que l'utilisateur est redirigé vers la page de connexion par défaut
      expect(find.text('Default Login Page'), findsOneWidget);
      expect(find.text('Protected Content'), findsNothing);
    });

    testWidgets('should handle authentication state changes', (
      WidgetTester tester,
    ) async {
      // Commencer sans utilisateur
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier redirection vers login
      expect(find.text('Login Page'), findsOneWidget);

      // Simuler la connexion de l'utilisateur
      mockAuth.setCurrentUser(MockUser());

      // Recréer le widget pour simuler le changement d'état
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le contenu protégé est maintenant affiché
      expect(find.text('Protected Content'), findsOneWidget);
      expect(find.text('Login Page'), findsNothing);
    });
  });

  group('ProtectedPage Tests', () {
    testWidgets('should work as a wrapper for AuthGuard', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockFirebaseAuth();
      mockAuth.setCurrentUser(MockUser());

      await tester.pumpWidget(
        MaterialApp(
          home: const ProtectedPage(
            child: Scaffold(body: Text('Protected Content')),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier que le contenu protégé est affiché
      expect(find.text('Protected Content'), findsOneWidget);
    });

    testWidgets('should use custom login route in ProtectedPage', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockFirebaseAuth();
      mockAuth.setCurrentUser(null);

      await tester.pumpWidget(
        MaterialApp(
          home: const ProtectedPage(
            loginRoute: '/custom-login',
            child: Scaffold(body: Text('Protected Content')),
          ),
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
            '/custom-login': (context) =>
                const Scaffold(body: Text('Custom Login Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier redirection vers login customisé
      expect(find.text('Custom Login Page'), findsOneWidget);
    });
  });

  group('AuthGuardMixin Tests', () {
    testWidgets('should provide protectPage method', (
      WidgetTester tester,
    ) async {
      final mockAuth = MockFirebaseAuth();
      mockAuth.setCurrentUser(MockUser());

      // Créer une classe test qui utilise le mixin
      final testWidget = _TestWidgetWithMixin();
      final protectedWidget = testWidget.protectPage(
        const Scaffold(body: Text('Protected Content')),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: protectedWidget,
          routes: {
            '/login': (context) => const Scaffold(body: Text('Login Page')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // Vérifier que le contenu protégé est affiché
      expect(find.text('Protected Content'), findsOneWidget);
    });
  });
}

// Classe test pour tester le mixin
class _TestWidgetWithMixin with AuthGuardMixin {}
