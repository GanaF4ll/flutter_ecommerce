import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/guards/auth_guard.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_ecommerce/services/service_factory.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:flutter_ecommerce/widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoriteService _favoriteService;
  Future<List<Favorite>>? _favorites;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeFavorites();
  }

  Future<void> _initializeFavorites() async {
    try {
      _favoriteService = await ServiceFactory.getFavoriteService();
      _loadFavorites();
    } catch (e) {
      // Erreur d'initialisation des favoris: $e
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadFavorites() {
    setState(() {
      _favorites = _favoriteService.getFavorites();
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Favorite favorite) async {
    if (favorite.product != null) {
      final success = await _favoriteService.removeProductFromFavorites(
        favorite.product!,
      );
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${favorite.product!.title} retiré des favoris'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        _loadFavorites(); // Recharger la liste
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    // Afficher une boîte de dialogue de confirmation
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider les favoris'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous vos favoris ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      final success = await _favoriteService.clearFavorites();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tous les favoris ont été supprimés'),
            backgroundColor: Colors.green,
          ),
        );
        _loadFavorites(); // Recharger la liste
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes Favoris'),
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllFavorites,
              tooltip: 'Vider les favoris',
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites == null
                ? const Center(child: Text('Erreur de chargement'))
                : FutureBuilder<List<Favorite>>(
                    future: _favorites!,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur lors du chargement des favoris',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Veuillez réessayer plus tard',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadFavorites,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        );
                      }

                      final favorites = snapshot.data ?? [];

                      if (favorites.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite_border,
                                size: 80,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Aucun favori',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ajoutez des produits à vos favoris pour les retrouver ici',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.grey[500]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/catalog'),
                                icon: const Icon(Icons.shopping_bag),
                                label: const Text('Parcourir les produits'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyan,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // En-tête avec le nombre de favoris
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[100],
                            child: Text(
                              '${favorites.length} produit${favorites.length > 1 ? 's' : ''} en favoris',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          // Liste des favoris
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: favorites.length,
                                itemBuilder: (context, index) {
                                  final favorite = favorites[index];
                                  if (favorite.product == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return Stack(
                                    children: [
                                      ProductCard(product: favorite.product!),
                                      // Bouton de suppression en haut à gauche
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: GestureDetector(
                                          onTap: () =>
                                              _removeFromFavorites(favorite),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(
                                                alpha: 0.9,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(6),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
