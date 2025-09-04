import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product/${product.id}'),
      child: Card(
        shadowColor: Colors.cyan,
        child: ListTile(
          title: Text(product.title),
          subtitle: Text('${product.price} €'),
          leading: Image.network(
            product.image,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
