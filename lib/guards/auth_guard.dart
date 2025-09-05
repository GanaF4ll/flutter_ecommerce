import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final String loginRoute;

  const AuthGuard({super.key, required this.child, this.loginRoute = '/login'});
  // final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // En cours de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Vérifier si l'utilisateur est authentifié
        if (snapshot.hasData && snapshot.data != null) {
          // Utilisateur authentifié, afficher la page demandée
          return child;
        } else {
          // Utilisateur non authentifié, rediriger vers la page de connexion
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(loginRoute);
          });

          // Afficher un indicateur de chargement en attendant la redirection
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

// Widget helper pour une protection plus simple
class ProtectedPage extends StatelessWidget {
  final Widget child;
  final String loginRoute;

  const ProtectedPage({
    super.key,
    required this.child,
    this.loginRoute = '/login',
  });

  @override
  Widget build(BuildContext context) {
    return AuthGuard(loginRoute: loginRoute, child: child);
  }
}

// Mixin pour les pages qui ont besoin de protection
mixin AuthGuardMixin {
  Widget protectPage(Widget page, {String loginRoute = '/login'}) {
    return AuthGuard(loginRoute: loginRoute, child: page);
  }
}
