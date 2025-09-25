import 'package:flutter/foundation.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_web.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_interface.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_web.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';

class RepositoryFactory {
  static ProductRepository? _productRepository;
  static CartRepositoryInterface? _cartRepository;
  static FavoriteRepositoryInterface? _favoriteRepository;

  // Singleton pour le ProductRepository
  static Future<ProductRepository> getProductRepository() async {
    _productRepository ??= ProductRepository();
    return _productRepository!;
  }

  // Factory pour CartRepository selon la plateforme
  static Future<CartRepositoryInterface> getCartRepository() async {
    if (_cartRepository != null) return _cartRepository!;

    final productRepository = await getProductRepository();

    if (kIsWeb) {
      _cartRepository = CartRepositoryWeb(productRepository: productRepository);
    } else {
      // Pour mobile, créer une version stub qui utilise les données locales
      _cartRepository = CartRepositoryWeb(productRepository: productRepository);
    }

    return _cartRepository!;
  }

  // Factory pour FavoriteRepository selon la plateforme
  static Future<FavoriteRepositoryInterface> getFavoriteRepository() async {
    if (_favoriteRepository != null) return _favoriteRepository!;

    final productRepository = await getProductRepository();

    if (kIsWeb) {
      _favoriteRepository =
          FavoriteRepositoryWeb(productRepository: productRepository);
    } else {
      // Pour mobile, utiliser aussi la version web temporairement
      _favoriteRepository =
          FavoriteRepositoryWeb(productRepository: productRepository);
    }

    return _favoriteRepository!;
  }

  // Reset pour les tests
  static void reset() {
    _productRepository = null;
    _cartRepository = null;
    _favoriteRepository = null;
  }
}
