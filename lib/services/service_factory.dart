import 'package:flutter_ecommerce/repositories/repository_factory.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_ecommerce/services/product_service.dart';

class ServiceFactory {
  static CartService? _cartService;
  static FavoriteService? _favoriteService;
  static ProductService? _productService;

  // Singleton pour CartService
  static Future<CartService> getCartService() async {
    if (_cartService != null) return _cartService!;

    final cartRepository = await RepositoryFactory.getCartRepository();
    _cartService = CartService(cartRepository: cartRepository);
    return _cartService!;
  }

  // Singleton pour FavoriteService
  static Future<FavoriteService> getFavoriteService() async {
    if (_favoriteService != null) return _favoriteService!;

    final favoriteRepository = await RepositoryFactory.getFavoriteRepository();
    _favoriteService = FavoriteService(favoriteRepository: favoriteRepository);
    return _favoriteService!;
  }

  // Singleton pour ProductService
  static Future<ProductService> getProductService() async {
    if (_productService != null) return _productService!;

    final productRepository = await RepositoryFactory.getProductRepository();
    _productService = ProductService(productRepository: productRepository);
    return _productService!;
  }

  // Reset pour les tests
  static void reset() {
    _cartService = null;
    _favoriteService = null;
    _productService = null;
  }
}
