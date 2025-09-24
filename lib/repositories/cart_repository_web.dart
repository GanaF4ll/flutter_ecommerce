import 'dart:convert';
import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepositoryWeb implements CartRepositoryInterface {
  final ProductRepository productRepository;
  static const String _cartKey = 'cart_items';

  CartRepositoryWeb({required this.productRepository});

  // Ajouter un produit au panier
  @override
  Future<int> addToCart(int productId, int quantity) async {
    final cartItems = await getCartItems();

    // Vérifier si le produit existe déjà dans le panier
    final existingItemIndex = cartItems.indexWhere(
      (item) => item.product.id == productId,
    );

    if (existingItemIndex != -1) {
      // Mettre à jour la quantité
      cartItems[existingItemIndex] = CartItem(
        id: cartItems[existingItemIndex].id,
        product: cartItems[existingItemIndex].product,
        quantity: cartItems[existingItemIndex].quantity + quantity,
      );
    } else {
      // Ajouter un nouvel item
      final product = await productRepository.fetchLocalProductById(
        productId.toString(),
      );
      cartItems.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
          product: product,
          quantity: quantity,
        ),
      );
    }

    await _saveCartItems(cartItems);
    return 1; // Simuler un ID
  }

  // Récupérer tous les items du panier
  @override
  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson == null) return [];

    try {
      final List<dynamic> cartList = json.decode(cartJson);
      List<CartItem> cartItems = [];

      for (var itemMap in cartList) {
        try {
          final product = await productRepository.fetchLocalProductById(
            itemMap['product_id'].toString(),
          );
          cartItems.add(
            CartItem(
              id: itemMap['id'],
              product: product,
              quantity: itemMap['quantity'],
            ),
          );
        } catch (e) {
          // Si le produit n'existe plus, on ignore cet item
          continue;
        }
      }

      return cartItems;
    } catch (e) {
      return [];
    }
  }

  // Récupérer un item du panier par ID de produit
  @override
  Future<CartItem?> getCartItemByProductId(int productId) async {
    final cartItems = await getCartItems();
    try {
      return cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Mettre à jour la quantité d'un item
  @override
  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      return removeFromCart(cartItemId);
    }

    final cartItems = await getCartItems();
    final itemIndex = cartItems.indexWhere((item) => item.id == cartItemId);

    if (itemIndex != -1) {
      cartItems[itemIndex] = CartItem(
        id: cartItems[itemIndex].id,
        product: cartItems[itemIndex].product,
        quantity: newQuantity,
      );
      await _saveCartItems(cartItems);
      return 1;
    }

    return 0;
  }

  // Supprimer un item du panier
  @override
  Future<int> removeFromCart(int cartItemId) async {
    final cartItems = await getCartItems();
    cartItems.removeWhere((item) => item.id == cartItemId);
    await _saveCartItems(cartItems);
    return 1;
  }

  // Vider le panier
  @override
  Future<int> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
    return 1;
  }

  // Récupérer le nombre total d'items dans le panier
  @override
  Future<int> getCartItemCount() async {
    final cartItems = await getCartItems();
    return cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Récupérer le prix total du panier
  @override
  Future<double> getCartTotal() async {
    final cartItems = await getCartItems();
    return cartItems.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Sauvegarder les items du panier
  Future<void> _saveCartItems(List<CartItem> cartItems) async {
    final prefs = await SharedPreferences.getInstance();
    final cartList = cartItems
        .map(
          (item) => {
            'id': item.id,
            'product_id': item.product.id,
            'quantity': item.quantity,
          },
        )
        .toList();

    await prefs.setString(_cartKey, json.encode(cartList));
  }
}
