import 'package:flutter_ecommerce/services/service_factory.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceFactory Tests', () {
    test('getCartService should return Future<CartService>', () {
      expect(ServiceFactory.getCartService(), isA<Future<CartService>>());
    });

    test('getFavoriteService should return Future<FavoriteService>', () {
      expect(
          ServiceFactory.getFavoriteService(), isA<Future<FavoriteService>>());
    });

    test('should be able to call factory methods multiple times', () {
      // Test qu'on peut appeler les méthodes plusieurs fois sans erreur
      expect(() {
        ServiceFactory.getCartService();
        ServiceFactory.getFavoriteService();
        ServiceFactory.getCartService();
        ServiceFactory.getFavoriteService();
      }, returnsNormally);
    });

    test('factory methods should return Future objects', () async {
      // Test que les méthodes retournent bien des Futures
      final cartServiceFuture = ServiceFactory.getCartService();
      final favoriteServiceFuture = ServiceFactory.getFavoriteService();

      expect(cartServiceFuture, isA<Future>());
      expect(favoriteServiceFuture, isA<Future>());
    });

    test('should handle concurrent calls gracefully', () {
      // Test les appels concurrents
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(ServiceFactory.getCartService());
        futures.add(ServiceFactory.getFavoriteService());
      }

      expect(futures, hasLength(10));
      expect(() => Future.wait(futures), returnsNormally);
    });
  });
}
