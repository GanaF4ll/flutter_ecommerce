import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/services/product_service.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';
import 'package:flutter_ecommerce/widgets/responsive_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();
  List<Product> _featuredProducts = [];
  List<Map<String, String>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Charger les produits vedettes (premiers 6 produits)
      final products = await _productService.getProducts();
      final categories = await _productService.getCategories();

      setState(() {
        _featuredProducts = products.take(6).toList();
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de chargement: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('E-Commerce Flutter'),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawer: const AppDrawer(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner principal
                      _buildHeroBanner(),

                      // Barre de recherche
                      _buildSearchBar(),

                      // Section des catégories
                      _buildCategoriesSection(),

                      // Section des produits vedettes
                      _buildFeaturedProductsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.cyan, Colors.blue],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 60, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Bienvenue dans votre',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              'E-Commerce Flutter',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher des produits...',
          prefixIcon: const Icon(Icons.search, color: Colors.cyan),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pushNamed(
              context,
              '/catalog',
              arguments: {'search': value},
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories populaires',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Adapter l'affichage des catégories selon la plateforme
          kIsWeb && MediaQuery.of(context).size.width > 800
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: _categories
                      .map((category) => _buildCategoryCard(category))
                      .toList(),
                )
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryCard(category);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, String> category) {
    final icons = {
      'electronique': Icons.devices,
      'vetements': Icons.checkroom,
      'maison-cuisine': Icons.kitchen,
      'sports-loisirs': Icons.sports,
      'beaute-sante': Icons.spa,
    };

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/catalog',
          arguments: {'category': category['slug']},
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icons[category['slug']] ?? Icons.category,
                size: 30,
                color: Colors.cyan,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                category['name'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Produits vedettes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/catalog');
                },
                child: const Text('Voir tout'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;

              // Adapter le nombre de colonnes selon la largeur
              if (constraints.maxWidth > 1400) {
                crossAxisCount = 6;
              } else if (constraints.maxWidth > 1200) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth > 900) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              } else {
                crossAxisCount = 2;
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _featuredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _featuredProducts[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
