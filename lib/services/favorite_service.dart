import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_interface.dart';

class FavoriteService {
  final FavoriteRepositoryInterface _favoriteRepository;

  FavoriteService({required FavoriteRepositoryInterface favoriteRepository})
    : _favoriteRepository = favoriteRepository;

  /// Ajouter un produit aux favoris
  Future<bool> addProductToFavorites(Product product) async {
    try {
      await _favoriteRepository.addToFavorites(product.id);
      return true;
    } catch (e) {
      // Erreur lors de l'ajout aux favoris: $e
      return false;
    }
  }

  /// Supprimer un produit des favoris
  Future<bool> removeProductFromFavorites(Product product) async {
    try {
      await _favoriteRepository.removeFromFavorites(product.id);
      return true;
    } catch (e) {
      // Erreur lors de la suppression des favoris: $e
      return false;
    }
  }

  /// Basculer l'état favori d'un produit
  Future<bool> toggleProductFavorite(Product product) async {
    try {
      return await _favoriteRepository.toggleFavorite(product.id);
    } catch (e) {
      // Erreur lors du basculement des favoris: $e
      return false;
    }
  }

  /// Vérifier si un produit est en favoris
  Future<bool> isProductFavorite(Product product) async {
    try {
      return await _favoriteRepository.isFavorite(product.id);
    } catch (e) {
      // Erreur lors de la vérification des favoris: $e
      return false;
    }
  }

  /// Vérifier si un produit est en favoris par ID
  Future<bool> isProductFavoriteById(int productId) async {
    try {
      return await _favoriteRepository.isFavorite(productId);
    } catch (e) {
      // Erreur lors de la vérification des favoris: $e
      return false;
    }
  }

  /// Récupérer tous les favoris
  Future<List<Favorite>> getFavorites() async {
    try {
      return await _favoriteRepository.getFavorites();
    } catch (e) {
      // Erreur lors de la récupération des favoris: $e
      return [];
    }
  }

  /// Récupérer tous les produits favoris
  Future<List<Product>> getFavoriteProducts() async {
    try {
      final favorites = await _favoriteRepository.getFavorites();
      return favorites
          .where((favorite) => favorite.product != null)
          .map((favorite) => favorite.product!)
          .toList();
    } catch (e) {
      // Erreur lors de la récupération des produits favoris: $e
      return [];
    }
  }

  /// Vider tous les favoris
  Future<bool> clearFavorites() async {
    try {
      await _favoriteRepository.clearFavorites();
      return true;
    } catch (e) {
      // Erreur lors de la suppression de tous les favoris: $e
      return false;
    }
  }

  /// Récupérer le nombre total de favoris
  Future<int> getFavoriteCount() async {
    try {
      return await _favoriteRepository.getFavoriteCount();
    } catch (e) {
      // Erreur lors du comptage des favoris: $e
      return 0;
    }
  }

  /// Récupérer un favori par ID de produit
  Future<Favorite?> getFavoriteByProductId(int productId) async {
    try {
      return await _favoriteRepository.getFavoriteByProductId(productId);
    } catch (e) {
      // Erreur lors de la récupération du favori: $e
      return null;
    }
  }
}
