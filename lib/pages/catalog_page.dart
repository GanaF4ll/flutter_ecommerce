import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Product>> futureProducts;
  final ProductRepository _productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    futureProducts = fetchLocalProducts();
    // futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    return await _productRepository.fetchProducts();
  }

  Future<List<Product>> fetchLocalProducts() async {
    return await _productRepository.fetchLocalProducts();
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Catalogue')),
        drawer: const AppDrawer(),
        body: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No products found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: snapshot.data![index]);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
