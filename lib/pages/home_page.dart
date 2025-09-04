import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Flutter Drawer Demo')),
        // drawer : le menu à gauche qui va nous permettre de naviguer entre les pages
        drawer: const AppDrawer(),
        body: const Center(child: Text('Welcome to Flutter Drawer Demo')),
      ),
    );
  }
}
