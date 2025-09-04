import 'package:flutter_ecommerce/entities/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;
}
