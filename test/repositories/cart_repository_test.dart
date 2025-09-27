import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/repositories/cart_repository.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'cart_repository_test.mocks.dart';

@GenerateMocks([ProductRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('CartRepository Tests', () {
    late Database database;
    late CartRepository cartRepository;
    late MockProductRepository mockProductRepository;
    late Product testProduct;

    setUp(() async {
      mockProductRepository = MockProductRepository();

      // Create in-memory database for testing
      database = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE cart (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              product_id INTEGER NOT NULL,
              quantity INTEGER NOT NULL
            )
          ''');
        },
      );

      cartRepository = CartRepository(
        database: database,
        productRepository: mockProductRepository,
      );

      const testRating = Rating(rate: 4.5, count: 100);
      testProduct = Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: testRating,
      );

      // Setup mock product repository
      when(mockProductRepository.fetchLocalProductById('1'))
          .thenAnswer((_) async => testProduct);
    });

    tearDown(() async {
      await database.close();
    });

    group('addToCart', () {
      test('should add new product to cart', () async {
        // Act
        final result = await cartRepository.addToCart(1, 2);

        // Assert
        expect(result, 1); // First inserted item should have ID 1

        // Verify the item was added
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(1));
        expect(cartItems[0]['product_id'], 1);
        expect(cartItems[0]['quantity'], 2);
      });

      test('should update quantity when product already exists in cart',
          () async {
        // Arrange - Add product first time
        await cartRepository.addToCart(1, 2);

        // Act - Add same product again
        final result = await cartRepository.addToCart(1, 3);

        // Assert
        expect(result, 1); // Updated row count

        // Verify quantity was updated, not new item added
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(1));
        expect(cartItems[0]['product_id'], 1);
        expect(cartItems[0]['quantity'], 5); // 2 + 3
      });
    });

    group('getCartItems', () {
      test('should return list of cart items', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});

        // Act
        final result = await cartRepository.getCartItems();

        // Assert
        expect(result, hasLength(1));
        expect(result[0].productId, 1);
        expect(result[0].quantity, 2);
        expect(result[0].productTitle, 'Test Product');
        verify(mockProductRepository.fetchLocalProductById('1')).called(1);
      });

      test('should remove cart item when product no longer exists', () async {
        // Arrange
        await database.insert('cart', {'product_id': 999, 'quantity': 2});
        when(mockProductRepository.fetchLocalProductById('999'))
            .thenThrow(Exception('Product not found'));

        // Act
        final result = await cartRepository.getCartItems();

        // Assert
        expect(result, hasLength(0));

        // Verify item was removed from database
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(0));
      });

      test('should return empty list when cart is empty', () async {
        // Act
        final result = await cartRepository.getCartItems();

        // Assert
        expect(result, hasLength(0));
      });
    });

    group('getCartItemByProductId', () {
      test('should return cart item when product exists in cart', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 3});

        // Act
        final result = await cartRepository.getCartItemByProductId(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.productId, 1);
        expect(result.quantity, 3);
        verify(mockProductRepository.fetchLocalProductById('1')).called(1);
      });

      test('should return null when product does not exist in cart', () async {
        // Act
        final result = await cartRepository.getCartItemByProductId(999);

        // Assert
        expect(result, isNull);
      });

      test('should return null when product no longer exists', () async {
        // Arrange
        await database.insert('cart', {'product_id': 999, 'quantity': 2});
        when(mockProductRepository.fetchLocalProductById('999'))
            .thenThrow(Exception('Product not found'));

        // Act
        final result = await cartRepository.getCartItemByProductId(999);

        // Assert
        expect(result, isNull);
      });
    });

    group('updateCartItemQuantity', () {
      test('should update quantity when new quantity is positive', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});

        // Act
        final result = await cartRepository.updateCartItemQuantity(1, 5);

        // Assert
        expect(result, 1); // Number of affected rows

        // Verify quantity was updated
        final cartItems =
            await database.query('cart', where: 'id = ?', whereArgs: [1]);
        expect(cartItems[0]['quantity'], 5);
      });

      test('should remove item when new quantity is zero or negative',
          () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});

        // Act
        final result = await cartRepository.updateCartItemQuantity(1, 0);

        // Assert
        expect(result, 1); // Number of affected rows (deleted)

        // Verify item was removed
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(0));
      });
    });

    group('removeFromCart', () {
      test('should remove cart item successfully', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});

        // Act
        final result = await cartRepository.removeFromCart(1);

        // Assert
        expect(result, 1); // Number of affected rows

        // Verify item was removed
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(0));
      });

      test('should return 0 when trying to remove non-existent item', () async {
        // Act
        final result = await cartRepository.removeFromCart(999);

        // Assert
        expect(result, 0);
      });
    });

    group('clearCart', () {
      test('should remove all cart items', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});
        await database.insert('cart', {'product_id': 2, 'quantity': 3});

        // Act
        final result = await cartRepository.clearCart();

        // Assert
        expect(result, 2); // Number of affected rows

        // Verify all items were removed
        final cartItems = await database.query('cart');
        expect(cartItems, hasLength(0));
      });

      test('should return 0 when cart is already empty', () async {
        // Act
        final result = await cartRepository.clearCart();

        // Assert
        expect(result, 0);
      });
    });

    group('getCartItemCount', () {
      test('should return total quantity of all items', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});
        await database.insert('cart', {'product_id': 2, 'quantity': 3});

        // Act
        final result = await cartRepository.getCartItemCount();

        // Assert
        expect(result, 5); // 2 + 3
      });

      test('should return 0 when cart is empty', () async {
        // Act
        final result = await cartRepository.getCartItemCount();

        // Assert
        expect(result, 0);
      });
    });

    group('getCartTotal', () {
      test('should return total price of all items in cart', () async {
        // Arrange
        await database.insert('cart', {'product_id': 1, 'quantity': 2});

        // Act
        final result = await cartRepository.getCartTotal();

        // Assert
        expect(result, 199.98); // 99.99 * 2
        verify(mockProductRepository.fetchLocalProductById('1')).called(1);
      });

      test('should return 0.0 when cart is empty', () async {
        // Act
        final result = await cartRepository.getCartTotal();

        // Assert
        expect(result, 0.0);
      });
    });
  });
}
