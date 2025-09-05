import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ProductPage extends StatefulWidget {
  final String id;

  const ProductPage({super.key, required this.id});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<Product> futureProduct;
  final ProductRepository _productRepository = ProductRepository();
  bool _isInitialized = false;
  bool _isLoading = false;
  late CartService _cartService;
  Product? _currentProduct;

  @override
  void initState() {
    super.initState();
    futureProduct = fetchLocalProductById(widget.id);
    _initializeCartService();
    // futureProduct = fetchProductById(widget.id);
  }

  Future<void> _initializeCartService() async {
    try {
      final database = await openDatabase(
        path.join(await getDatabasesPath(), 'cart_database.db'),
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE cart (id INTEGER PRIMARY KEY AUTOINCREMENT, product_id INTEGER, quantity INTEGER)',
          );
        },
      );
      final productRepository = ProductRepository();
      final cartRepository = CartRepository(
        database: database,
        productRepository: productRepository,
      );
      _cartService = CartService(cartRepository: cartRepository);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Erreur d\'initialisation du cart service: $e');
    }
  }

  Future<Product> fetchLocalProductById(String id) async {
    return await _productRepository.fetchLocalProductById(id);
  }
  // Future<Product> fetchProductById(String id) async {
  //   return await _productRepository.fetchProductById(id);
  // }

  Future<void> _addToCart() async {
    if (!_isInitialized || _currentProduct == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _cartService.addProductToCart(_currentProduct!);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_currentProduct!.title} ajouté au panier'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Voir le panier',
              onPressed: () => Navigator.pushNamed(context, '/cart'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'ajout au panier'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(title: const Text('Product')),
        body: FutureBuilder<Product>(
          future: futureProduct,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final product = snapshot.data!;
              _currentProduct =
                  product; // Stocker le produit pour l'utiliser dans _addToCart
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image du produit
                    Center(
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            product.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre du produit
                    Text(
                      product.title ?? 'No title',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Prix
                    Text(
                      '${product.price ?? 0} €',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    ...[
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Rating si disponible
                    ...[
                      Text(
                        'Évaluation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating.rate ?? 0}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(' (${product.rating.count ?? 0} avis)'),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Bouton d'ajout au panier
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isInitialized && !_isLoading
                            ? _addToCart
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Ajouter au panier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
