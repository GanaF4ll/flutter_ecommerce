import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';

/// Mock AuthGuard qui retourne toujours l'enfant sans redirection
class MockAuthGuard extends StatelessWidget {
  final Widget child;

  const MockAuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Toujours retourner l'enfant sans vérification d'auth
    return child;
  }
}

/// Helper pour créer un widget de test avec MockAuthGuard
Widget createTestWidgetWithMockAuth(Widget child) {
  return MaterialApp(
    home: MockAuthGuard(child: child),
    routes: {
      '/login': (context) => const Scaffold(body: Text('Login Page')),
      '/register': (context) => const Scaffold(body: Text('Register Page')),
      '/home': (context) => const Scaffold(body: Text('Home Page')),
      '/catalog': (context) => const Scaffold(body: Text('Catalog Page')),
      '/cart': (context) => const Scaffold(body: Text('Cart Page')),
      '/favorites': (context) => const Scaffold(body: Text('Favorites Page')),
      '/product': (context) => const Scaffold(body: Text('Product Page')),
    },
  );
}

/// Extension pour remplacer AuthGuard par MockAuthGuard dans les tests
extension AuthGuardTestExtension on Widget {
  Widget replaceAuthGuardWithMock() {
    if (this is AuthGuard) {
      final authGuard = this as AuthGuard;
      return MockAuthGuard(child: authGuard.child);
    }
    return this;
  }
}
