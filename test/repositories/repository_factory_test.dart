import 'package:flutter_ecommerce/repositories/repository_factory.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RepositoryFactory Tests', () {
    test('getCartRepository should return Future<CartRepositoryInterface>', () {
      expect(RepositoryFactory.getCartRepository(),
          isA<Future<CartRepositoryInterface>>());
    });

    test(
        'getFavoriteRepository should return Future<FavoriteRepositoryInterface>',
        () {
      expect(RepositoryFactory.getFavoriteRepository(),
          isA<Future<FavoriteRepositoryInterface>>());
    });

    test('should be able to call factory methods multiple times', () {
      // Test qu'on peut appeler les méthodes plusieurs fois sans erreur
      expect(() {
        RepositoryFactory.getCartRepository();
        RepositoryFactory.getFavoriteRepository();
        RepositoryFactory.getCartRepository();
        RepositoryFactory.getFavoriteRepository();
      }, returnsNormally);
    });

    test('factory methods should return Future objects', () {
      // Test que les méthodes retournent bien des Futures
      final cartRepoFuture = RepositoryFactory.getCartRepository();
      final favoriteRepoFuture = RepositoryFactory.getFavoriteRepository();

      expect(cartRepoFuture, isA<Future>());
      expect(favoriteRepoFuture, isA<Future>());
    });

    test('should handle concurrent calls gracefully', () {
      // Test les appels concurrents
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(RepositoryFactory.getCartRepository());
        futures.add(RepositoryFactory.getFavoriteRepository());
      }

      expect(futures, hasLength(10));
      expect(() => Future.wait(futures), returnsNormally);
    });

    test('should provide consistent interface types', () {
      // Vérifier que les types retournés sont cohérents
      final cartRepo = RepositoryFactory.getCartRepository();
      final favoriteRepo = RepositoryFactory.getFavoriteRepository();

      expect(cartRepo, isA<Future<CartRepositoryInterface>>());
      expect(favoriteRepo, isA<Future<FavoriteRepositoryInterface>>());
    });
  });
}
