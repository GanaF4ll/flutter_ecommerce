import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final dynamic product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.cyan,
      child: ListTile(
        title: Text(product['title'] ?? 'No title'),
        subtitle: Text('${product['price'] ?? 0} €'),
        leading: product['image'] != null
            ? Image.network(
                product['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.shopping_bag),
      ),
    );
  }
}
