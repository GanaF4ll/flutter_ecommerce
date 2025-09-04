import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/cart_page.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';

import 'pages/login_page.dart';
import 'pages/product_page.dart';
import 'pages/register_page.dart';

void main() async {
  // initialise les bindings en flutter
  WidgetsFlutterBinding.ensureInitialized();
  // ici on peut utiliser les services de firebase sur notre app
  await Firebase.initializeApp();

  // final database = await openDatabase(
  //   join(await getDatabasesPath(), 'cart_database.db'),
  //   onCreate: (db, version) {
  //     return db.execute(
  //       'CREATE TABLE cart (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, quantity INTEGER)',
  //     );
  //   },
  // );
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
        '/cart': (_) => const CartPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/product/') == true) {
          final id = settings.name!.split('/')[2];
          return MaterialPageRoute(builder: (_) => ProductPage(id: id));
        }
        return null;
      },
    );
  }
}
