import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() async {
  // initialise les bindings en flutter
  WidgetsFlutterBinding.ensureInitialized();
  // ici on peut utiliser les services de firebase sur notre app
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.cyan, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/catalog': (_) => const CatalogPage(),
      },
    );
  }
}
