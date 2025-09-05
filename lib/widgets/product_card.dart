import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late CartService _cartService;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCartService();
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

  Future<void> _addToCart() async {
    if (!_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _cartService.addProductToCart(widget.product);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.title} ajouté au panier'),
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
    return Card(
      shadowColor: Colors.cyan,
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${widget.product.price.toStringAsFixed(2)} €',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.product.image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            onTap: () =>
                Navigator.pushNamed(context, '/product/${widget.product.id}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isInitialized && !_isLoading
                        ? _addToCart
                        : null,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_shopping_cart),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/product/${widget.product.id}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                  child: const Text('Détails'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
