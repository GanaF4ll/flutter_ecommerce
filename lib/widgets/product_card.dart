import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_ecommerce/services/service_factory.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late CartService _cartService;
  late FavoriteService _favoriteService;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _isFavorite = false;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialiser les services via les factory
      _cartService = await ServiceFactory.getCartService();
      _favoriteService = await ServiceFactory.getFavoriteService();

      // Vérifier si le produit est en favoris
      final isFavorite = await _favoriteService.isProductFavorite(
        widget.product,
      );

      setState(() {
        _isInitialized = true;
        _isFavorite = isFavorite;
      });
    } catch (e) {
      // Erreur d'initialisation des services: $e
      setState(() {
        _isInitialized = true; // Même en cas d'erreur, marquer comme initialisé
      });
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

  Future<void> _toggleFavorite() async {
    if (!_isInitialized) return;

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final newFavoriteStatus = await _favoriteService.toggleProductFavorite(
        widget.product,
      );
      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus
                  ? '${widget.product.title} ajouté aux favoris'
                  : '${widget.product.title} retiré des favoris',
            ),
            backgroundColor: newFavoriteStatus ? Colors.pink : Colors.orange,
            duration: const Duration(seconds: 2),
            action: newFavoriteStatus
                ? SnackBarAction(
                    label: 'Voir les favoris',
                    onPressed: () => Navigator.pushNamed(context, '/favorites'),
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la gestion des favoris'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: kIsWeb ? 2 : 1,
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, '/product/${widget.product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit en haut
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Image.network(
                    widget.product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
                // Icône favoris en haut à droite
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isTogglingFavorite
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.pink,
                              ),
                            )
                          : Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite ? Colors.pink : Colors.grey,
                            ),
                      onPressed: _isInitialized && !_isTogglingFavorite
                          ? _toggleFavorite
                          : null,
                      iconSize: 20,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ),
                // Badge "LOW STOCK" si nécessaire
                if (widget.product.rating.count < 50)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Text(
                        'LOW STOCK',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Informations du produit
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre du produit
                    Expanded(
                      child: Text(
                        widget.product.title,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Prix et bouton
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${widget.product.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        // Bouton Ajouter au panier à droite
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              onTap: _isInitialized && !_isLoading
                                  ? _addToCart
                                  : null,
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
