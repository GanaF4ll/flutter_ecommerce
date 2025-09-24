import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';

class CartService {
  final CartRepositoryInterface _cartRepository;

  CartService({required CartRepositoryInterface cartRepository})
    : _cartRepository = cartRepository;

  /// Ajouter un produit au panier
  Future<bool> addProductToCart(Product product, {int quantity = 1}) async {
    try {
      await _cartRepository.addToCart(product.id, quantity);
      return true;
    } catch (e) {
      // Erreur lors de l'ajout au panier: $e
      return false;
    }
  }

  /// Récupérer tous les items du panier
  Future<List<CartItem>> getCartItems() async {
    try {
      return await _cartRepository.getCartItems();
    } catch (e) {
      // Erreur lors de la récupération du panier: $e
      return [];
    }
  }

  /// Mettre à jour la quantité d'un item
  Future<bool> updateQuantity(CartItem item, int newQuantity) async {
    try {
      if (item.id != null) {
        await _cartRepository.updateCartItemQuantity(item.id!, newQuantity);
        return true;
      }
      return false;
    } catch (e) {
      // Erreur lors de la mise à jour de la quantité: $e
      return false;
    }
  }

  /// Supprimer un item du panier
  Future<bool> removeFromCart(CartItem item) async {
    try {
      if (item.id != null) {
        await _cartRepository.removeFromCart(item.id!);
        return true;
      }
      return false;
    } catch (e) {
      // Erreur lors de la suppression: $e
      return false;
    }
  }

  /// Vider complètement le panier
  Future<bool> clearCart() async {
    try {
      await _cartRepository.clearCart();
      return true;
    } catch (e) {
      // Erreur lors de la suppression du panier: $e
      return false;
    }
  }

  /// Récupérer le nombre total d'items
  Future<int> getCartItemCount() async {
    try {
      return await _cartRepository.getCartItemCount();
    } catch (e) {
      // Erreur lors du comptage des items: $e
      return 0;
    }
  }

  /// Récupérer le prix total du panier
  Future<double> getCartTotal() async {
    try {
      return await _cartRepository.getCartTotal();
    } catch (e) {
      // Erreur lors du calcul du total: $e
      return 0.0;
    }
  }

  /// Vérifier si un produit est dans le panier
  Future<bool> isProductInCart(int productId) async {
    try {
      final item = await _cartRepository.getCartItemByProductId(productId);
      return item != null;
    } catch (e) {
      // Erreur lors de la vérification: $e
      return false;
    }
  }

  /// Récupérer la quantité d'un produit dans le panier
  Future<int> getProductQuantityInCart(int productId) async {
    try {
      final item = await _cartRepository.getCartItemByProductId(productId);
      return item?.quantity ?? 0;
    } catch (e) {
      // Erreur lors de la récupération de la quantité: $e
      return 0;
    }
  }
}
