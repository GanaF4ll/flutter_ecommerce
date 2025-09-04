import 'package:flutter_ecommerce/entities/product.dart';

class Cart {
  final List<Product> products;

  Cart({required this.products});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(products: json['products']);
  }

  Map<String, dynamic> toJson() {
    return {'products': products};
  }
}
