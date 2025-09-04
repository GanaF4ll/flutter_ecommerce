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

  @override
  Widget build(BuildContext context) {
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
            title: const Text('Home'),
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
            leading: const Icon(Icons.login, color: Colors.green),
            title: const Text('Se connecter'),
            onTap: () => _go(context, '/login'),
          ),
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.cyan),
            title: const Text('S\'inscrire'),
            onTap: () => _go(context, '/register'),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Se déconnecter'),
            onTap: () => _go(context, '/register'),
          ),
        ],
      ),
    );
  }
}
