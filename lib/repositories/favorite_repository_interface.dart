import 'package:flutter_ecommerce/entities/favorite.dart';

abstract class FavoriteRepositoryInterface {
  Future<int> addToFavorites(int productId);
  Future<int> removeFromFavorites(int productId);
  Future<bool> isFavorite(int productId);
  Future<Favorite?> getFavoriteByProductId(int productId);
  Future<List<Favorite>> getFavorites();
  Future<int> clearFavorites();
  Future<int> getFavoriteCount();
  Future<bool> toggleFavorite(int productId);
}
