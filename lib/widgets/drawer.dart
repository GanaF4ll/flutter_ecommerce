import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    // Ferme le drawer puis remplace la route courante pour éviter d'empiler
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.cyan),
            child: Text(
              'Flutter E-commerce',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.cyan),
            title: const Text('Accueil'),
            onTap: () => _go(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.euro_outlined, color: Colors.cyan),
            title: const Text('Catalogue'),
            onTap: () => _go(context, '/catalog'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Colors.cyan),
            title: const Text('Panier'),
            onTap: () => _go(context, '/cart'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.pink),
            title: const Text('Favoris'),
            onTap: () => _go(context, '/favorites'),
          ),
          // Afficher login/register seulement si l'utilisateur n'est pas connecté
          if (!isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Se connecter'),
              onTap: () => _go(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.cyan),
              title: const Text('S\'inscrire'),
              onTap: () => _go(context, '/register'),
            ),
          ],
          // Afficher logout seulement si l'utilisateur est connecté
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter'),
              onTap: () => _logout(context),
            ),
        ],
      ),
    );
  }
}
