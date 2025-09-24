import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/cart_page.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_ecommerce/pages/favorites_page.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/product_page.dart';
import 'pages/register_page.dart';
import 'repositories/cart_repository.dart';
import 'repositories/cart_repository_web.dart';
import 'repositories/favorite_repository.dart';
import 'repositories/favorite_repository_web.dart';
import 'repositories/product_repository.dart';
import 'services/cart_service.dart';
import 'services/favorite_service.dart';

void main() async {
  // initialise les bindings en flutter
  WidgetsFlutterBinding.ensureInitialized();
  // ici on peut utiliser les services de firebase sur notre app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialiser la base de données seulement sur les plateformes mobiles
  Database? database;
  if (!kIsWeb) {
    database = await openDatabase(
      join(await getDatabasesPath(), 'cart_database.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cart (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, quantity INTEGER)',
        );
      },
    );
  }

  // Initialiser les repositories selon la plateforme
  final productRepository = ProductRepository();

  if (kIsWeb) {
    // Utiliser les repositories web avec SharedPreferences
    final cartRepository = CartRepositoryWeb(
      productRepository: productRepository,
    );
    final favoriteRepository = FavoriteRepositoryWeb(
      productRepository: productRepository,
    );

    // Initialiser les services
    final cartService = CartService(cartRepository: cartRepository);
    final favoriteService = FavoriteService(
      favoriteRepository: favoriteRepository,
    );

    runApp(MyApp(cartService: cartService, favoriteService: favoriteService));
  } else {
    // Utiliser les repositories mobiles avec SQLite
    final cartRepository = CartRepository(
      database: database!,
      productRepository: productRepository,
    );
    final favoriteRepository = FavoriteRepository(
      database: database,
      productRepository: productRepository,
    );

    // Initialiser les services
    final cartService = CartService(cartRepository: cartRepository);
    final favoriteService = FavoriteService(
      favoriteRepository: favoriteRepository,
    );

    runApp(MyApp(cartService: cartService, favoriteService: favoriteService));
  }
}

class MyApp extends StatelessWidget {
  final CartService? cartService;
  final FavoriteService? favoriteService;

  const MyApp({super.key, this.cartService, this.favoriteService});

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
        '/favorites': (_) => const FavoritesPage(),
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
