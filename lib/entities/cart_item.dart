import 'package:flutter_ecommerce/entities/product.dart';

class CartItem {
  final int? id;
  final Product product;
  final int quantity;

  const CartItem({this.id, required this.product, required this.quantity});

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {'id': id, 'product_id': product.id, 'quantity': quantity};
  }

  factory CartItem.fromMap(Map<String, dynamic> map, Product product) {
    return CartItem(id: map['id'], product: product, quantity: map['quantity']);
  }

  CartItem copyWith({int? id, Product? product, int? quantity}) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
