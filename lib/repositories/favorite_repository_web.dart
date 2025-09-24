import 'dart:convert';
import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_interface.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteRepositoryWeb implements FavoriteRepositoryInterface {
  final ProductRepository productRepository;
  static const String _favoritesKey = 'favorite_items';

  FavoriteRepositoryWeb({required this.productRepository});

  // Ajouter un produit aux favoris
  @override
  Future<int> addToFavorites(int productId) async {
    final favorites = await getFavorites();

    // Vérifier si le produit n'est pas déjà en favoris
    final existingFavorite = await getFavoriteByProductId(productId);

    if (existingFavorite != null) {
      // Le produit est déjà en favoris, ne rien faire
      return existingFavorite.id ?? 0;
    }

    // Ajouter aux favoris
    final product = await productRepository.fetchLocalProductById(
      productId.toString(),
    );
    final newFavorite = Favorite(
      id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
      productId: productId,
      product: product,
      addedAt: DateTime.now(),
    );

    favorites.add(newFavorite);
    await _saveFavorites(favorites);
    return newFavorite.id ?? 0;
  }

  // Supprimer un produit des favoris
  @override
  Future<int> removeFromFavorites(int productId) async {
    final favorites = await getFavorites();
    final initialLength = favorites.length;
    favorites.removeWhere((favorite) => favorite.productId == productId);
    await _saveFavorites(favorites);
    return initialLength - favorites.length;
  }

  // Vérifier si un produit est en favoris
  @override
  Future<bool> isFavorite(int productId) async {
    final favorites = await getFavorites();
    return favorites.any((favorite) => favorite.productId == productId);
  }

  // Récupérer un favori par ID de produit
  @override
  Future<Favorite?> getFavoriteByProductId(int productId) async {
    final favorites = await getFavorites();
    try {
      return favorites.firstWhere(
        (favorite) => favorite.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  // Récupérer tous les favoris
  @override
  Future<List<Favorite>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);

    if (favoritesJson == null) return [];

    try {
      final List<dynamic> favoritesList = json.decode(favoritesJson);
      List<Favorite> favorites = [];

      for (var favoriteMap in favoritesList) {
        try {
          final product = await productRepository.fetchLocalProductById(
            favoriteMap['product_id'].toString(),
          );
          favorites.add(
            Favorite(
              id: favoriteMap['id'] ?? DateTime.now().millisecondsSinceEpoch,
              productId: favoriteMap['product_id'] as int,
              product: product,
              addedAt: DateTime.parse(favoriteMap['added_at']),
            ),
          );
        } catch (e) {
          // Si le produit n'existe plus, on ignore ce favori
          continue;
        }
      }

      // Trier par date d'ajout (les plus récents en premier)
      favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return favorites;
    } catch (e) {
      return [];
    }
  }

  // Vider tous les favoris
  @override
  Future<int> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKey);
    return 1;
  }

  // Récupérer le nombre total de favoris
  @override
  Future<int> getFavoriteCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  // Basculer l'état favori d'un produit (ajouter si pas présent, supprimer si présent)
  @override
  Future<bool> toggleFavorite(int productId) async {
    final isCurrentlyFavorite = await isFavorite(productId);

    if (isCurrentlyFavorite) {
      await removeFromFavorites(productId);
      return false; // Plus en favoris
    } else {
      await addToFavorites(productId);
      return true; // Maintenant en favoris
    }
  }

  // Sauvegarder les favoris
  Future<void> _saveFavorites(List<Favorite> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = favorites
        .map(
          (favorite) => {
            'id': favorite.id ?? DateTime.now().millisecondsSinceEpoch,
            'product_id': favorite.productId,
            'added_at': favorite.addedAt.toIso8601String(),
          },
        )
        .toList();

    await prefs.setString(_favoritesKey, json.encode(favoritesList));
  }
}
