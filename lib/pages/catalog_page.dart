import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/repositories/repository_factory.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_ecommerce/widgets/product_filter.dart';
import 'package:flutter_ecommerce/widgets/responsive_layout.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Product>> futureProducts;
  late Future<dynamic> _productRepository;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _productRepository = RepositoryFactory.getProductRepository();
    futureProducts = fetchLocalProducts();
  }

  void onCategoryChanged(String? category) {
    setState(() {
      selectedCategory = category;
      if (category == null) {
        futureProducts = fetchLocalProducts();
      } else {
        futureProducts = fetchLocalProductsByCategory(category);
      }
    });
  }

  Future<List<Product>> fetchProducts() async {
    final repo = await _productRepository;
    return await repo.fetchProducts();
  }

  Future<List<Product>> fetchLocalProducts() async {
    final repo = await _productRepository;
    return await repo.fetchLocalProducts();
  }

  Future<List<Product>> fetchLocalProductsByCategory(String category) async {
    final repo = await _productRepository;
    return await repo.fetchLocalProductsByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catalogue'),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            ProductFilter(
              selectedCategory: selectedCategory,
              onCategoryChanged: onCategoryChanged,
            ),
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products found'));
                  } else {
                    return ResponsiveContainer(
                      child: ResponsiveGridView(
                        childAspectRatio: 0.7,
                        children: snapshot.data!
                            .map((product) => ProductCard(product: product))
                            .toList(),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
