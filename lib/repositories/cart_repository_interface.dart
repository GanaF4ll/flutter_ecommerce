import 'package:flutter_ecommerce/entities/cart_item.dart';

abstract class CartRepositoryInterface {
  Future<int> addToCart(int productId, int quantity);
  Future<List<CartItem>> getCartItems();
  Future<CartItem?> getCartItemByProductId(int productId);
  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity);
  Future<int> removeFromCart(int cartItemId);
  Future<int> clearCart();
  Future<int> getCartItemCount();
  Future<double> getCartTotal();
}
