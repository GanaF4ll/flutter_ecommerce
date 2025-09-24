// Test runner principal pour Flutter E-commerce
//
// Ce fichier importe et exécute tous les tests de l'application
// pour assurer une couverture complète des fonctionnalités.

import 'package:flutter_test/flutter_test.dart';

import 'entities/cart_item_test.dart' as cart_item_tests;
import 'entities/favorite_test.dart' as favorite_tests;
// Tests des entités
import 'entities/product_test.dart' as product_tests;
import 'entities/rating_test.dart' as rating_tests;
// Tests des guards
import 'guards/auth_guard_test.dart' as auth_guard_tests;
import 'pages/catalog_page_test.dart' as catalog_page_tests;
import 'pages/favorites_page_test.dart' as favorites_page_tests;
// Tests des pages
import 'pages/home_page_test.dart' as home_page_tests;
// Tests des services et repositories intégrés dans les entités
// Test principal de l'application
import 'widget_test.dart' as main_app_tests;
import 'widgets/drawer_test.dart' as drawer_tests;
// Tests des widgets
import 'widgets/product_card_test.dart' as product_card_tests;

void main() {
  group('Flutter E-commerce - Tests Complets', () {
    group('🏗️ Entités', () {
      product_tests.main();
      rating_tests.main();
      cart_item_tests.main();
      favorite_tests.main();
    });

    group('🎨 Widgets', () {
      product_card_tests.main();
      drawer_tests.main();
    });

    group('🛡️ Guards & Auth', () {
      auth_guard_tests.main();
    });

    group('📱 Pages', () {
      home_page_tests.main();
      catalog_page_tests.main();
      favorites_page_tests.main();
    });

    group('🚀 Application Principale', () {
      main_app_tests.main();
    });
  });
}
