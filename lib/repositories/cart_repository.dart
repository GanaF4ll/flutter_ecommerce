import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:sqflite/sqlite_api.dart';

class CartRepository {
  final Database database;
  final ProductRepository productRepository;

  CartRepository({required this.database, required this.productRepository});

  // Ajouter un produit au panier
  Future<int> addToCart(int productId, int quantity) async {
    // Vérifier si le produit existe déjà dans le panier
    final existingItem = await getCartItemByProductId(productId);

    if (existingItem != null) {
      // Mettre à jour la quantité
      return updateCartItemQuantity(
        existingItem.id!,
        existingItem.quantity + quantity,
      );
    } else {
      // Ajouter un nouvel item
      return database.insert('cart', {
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  // Récupérer tous les items du panier
  Future<List<CartItem>> getCartItems() async {
    final List<Map<String, dynamic>> cartMaps = await database.query('cart');
    List<CartItem> cartItems = [];

    for (var cartMap in cartMaps) {
      try {
        final product = await productRepository.fetchLocalProductById(
          cartMap['product_id'].toString(),
        );
        cartItems.add(CartItem.fromMap(cartMap, product));
      } catch (e) {
        // Si le produit n'existe plus, on supprime l'item du panier
        await removeFromCart(cartMap['id']);
      }
    }

    return cartItems;
  }

  // Récupérer un item du panier par ID de produit
  Future<CartItem?> getCartItemByProductId(int productId) async {
    final List<Map<String, dynamic>> cartMaps = await database.query(
      'cart',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    if (cartMaps.isNotEmpty) {
      try {
        final product = await productRepository.fetchLocalProductById(
          productId.toString(),
        );
        return CartItem.fromMap(cartMaps.first, product);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Mettre à jour la quantité d'un item
  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      return removeFromCart(cartItemId);
    }

    return database.update(
      'cart',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [cartItemId],
    );
  }

  // Supprimer un item du panier
  Future<int> removeFromCart(int cartItemId) async {
    return database.delete('cart', where: 'id = ?', whereArgs: [cartItemId]);
  }

  // Vider le panier
  Future<int> clearCart() async {
    return database.delete('cart');
  }

  // Récupérer le nombre total d'items dans le panier
  Future<int> getCartItemCount() async {
    final result = await database.rawQuery(
      'SELECT SUM(quantity) as total FROM cart',
    );
    return result.first['total'] as int? ?? 0;
  }

  // Récupérer le prix total du panier
  Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }
}
