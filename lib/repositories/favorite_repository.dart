import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:sqflite/sqlite_api.dart';

class FavoriteRepository {
  final Database database;
  final ProductRepository productRepository;

  FavoriteRepository({required this.database, required this.productRepository});

  // Ajouter un produit aux favoris
  Future<int> addToFavorites(int productId) async {
    // Vérifier si le produit n'est pas déjà en favoris
    final existingFavorite = await getFavoriteByProductId(productId);

    if (existingFavorite != null) {
      // Le produit est déjà en favoris, ne rien faire
      return existingFavorite.id!;
    }

    // Ajouter aux favoris
    return database.insert('favorites', {
      'product_id': productId,
      'added_at': DateTime.now().toIso8601String(),
    });
  }

  // Supprimer un produit des favoris
  Future<int> removeFromFavorites(int productId) async {
    return database.delete(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // Vérifier si un produit est en favoris
  Future<bool> isFavorite(int productId) async {
    final result = await database.query(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  // Récupérer un favori par ID de produit
  Future<Favorite?> getFavoriteByProductId(int productId) async {
    final List<Map<String, dynamic>> favoriteMaps = await database.query(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (favoriteMaps.isNotEmpty) {
      try {
        final product = await productRepository.fetchLocalProductById(
          productId.toString(),
        );
        return Favorite.fromMap(favoriteMaps.first, product: product);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Récupérer tous les favoris
  Future<List<Favorite>> getFavorites() async {
    final List<Map<String, dynamic>> favoriteMaps = await database.query(
      'favorites',
      orderBy: 'added_at DESC', // Les plus récents en premier
    );
    List<Favorite> favorites = [];

    for (var favoriteMap in favoriteMaps) {
      try {
        final product = await productRepository.fetchLocalProductById(
          favoriteMap['product_id'].toString(),
        );
        favorites.add(Favorite.fromMap(favoriteMap, product: product));
      } catch (e) {
        // Si le produit n'existe plus, on supprime le favori
        await database.delete(
          'favorites',
          where: 'id = ?',
          whereArgs: [favoriteMap['id']],
        );
      }
    }

    return favorites;
  }

  // Vider tous les favoris
  Future<int> clearFavorites() async {
    return database.delete('favorites');
  }

  // Récupérer le nombre total de favoris
  Future<int> getFavoriteCount() async {
    final result = await database.rawQuery(
      'SELECT COUNT(*) as total FROM favorites',
    );
    return result.first['total'] as int? ?? 0;
  }

  // Basculer l'état favori d'un produit (ajouter si pas présent, supprimer si présent)
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
}
