import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/widgets/cart_item_card.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late CartService _cartService;
  late Future<List<CartItem>> _cartItems;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      final database = await openDatabase(
        path.join(await getDatabasesPath(), 'cart_database.db'),
      );
      final productRepository = ProductRepository();
      final cartRepository = CartRepository(
        database: database,
        productRepository: productRepository,
      );
      _cartService = CartService(cartRepository: cartRepository);
      _loadCartItems();
    } catch (e) {
      // Erreur d'initialisation du panier: $e
    }
  }

  void _loadCartItems() {
    setState(() {
      _cartItems = _cartService.getCartItems();
      _isLoading = false;
    });
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    final success = await _cartService.updateQuantity(item, newQuantity);
    if (success) {
      _loadCartItems();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Quantité mise à jour')));
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final success = await _cartService.removeFromCart(item);
    if (success) {
      _loadCartItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit retiré du panier')),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text('Êtes-vous sûr de vouloir vider le panier ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vider'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _cartService.clearCart();
      if (success) {
        _loadCartItems();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Panier vidé')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AuthGuard(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Panier'),
          actions: [
            IconButton(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_forever),
              tooltip: 'Vider le panier',
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder<List<CartItem>>(
          future: _cartItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final cartItems = snapshot.data ?? [];

            if (cartItems.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Votre panier est vide',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajoutez des produits pour commencer vos achats',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            double total = cartItems.fold(
              0.0,
              (sum, item) => sum + item.totalPrice,
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return CartItemCard(
                        item: item,
                        onRemove: () => _removeItem(item),
                        onUpdateQuantity: (newQuantity) =>
                            _updateQuantity(item, newQuantity),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${total.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fonctionnalité de commande à venir !',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Passer la commande',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
