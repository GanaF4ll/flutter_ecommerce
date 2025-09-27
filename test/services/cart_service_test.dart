import 'package:flutter_ecommerce/entities/cart_item.dart';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/repositories/cart_repository_interface.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock simple pour les tests
class MockCartRepository implements CartRepositoryInterface {
  List<CartItem> _items = [];
  int _nextId = 1;

  @override
  Future<int> addToCart(int productId, int quantity) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == productId);
    if (existingIndex != -1) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + quantity,
      );
      return _items[existingIndex].id!;
    } else {
      final newItem = CartItem(
        id: _nextId++,
        product: _createMockProduct(productId),
        quantity: quantity,
      );
      _items.add(newItem);
      return newItem.id!;
    }
  }

  @override
  Future<List<CartItem>> getCartItems() async => List.from(_items);

  @override
  Future<CartItem?> getCartItemByProductId(int productId) async {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateCartItemQuantity(int cartItemId, int newQuantity) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
      return 1;
    }
    return 0;
  }

  @override
  Future<int> removeFromCart(int cartItemId) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index != -1) {
      _items.removeAt(index);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> clearCart() async {
    final count = _items.length;
    _items.clear();
    _nextId = 1;
    return count;
  }

  @override
  Future<int> getCartItemCount() async {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  @override
  Future<double> getCartTotal() async {
    return _items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  Product _createMockProduct(int id) {
    return Product(
      id: id,
      title: 'Product $id',
      description: 'Description $id',
      price: 10.0 * id,
      image: 'https://example.com/image$id.jpg',
      category: 'category',
      rating: const Rating(rate: 4.0, count: 50),
    );
  }
}

void main() {
  group('CartService Tests', () {
    late CartService cartService;
    late MockCartRepository mockRepository;
    late Product testProduct;

    setUp(() {
      mockRepository = MockCartRepository();
      cartService = CartService(cartRepository: mockRepository);

      const testRating = Rating(rate: 4.5, count: 100);
      testProduct = const Product(
        id: 1,
        title: 'Test Product',
        description: 'Test Description',
        price: 99.99,
        image: 'https://example.com/image.jpg',
        category: 'electronics',
        rating: testRating,
      );
    });

    test('should create CartService instance', () {
      expect(cartService, isNotNull);
      expect(cartService, isA<CartService>());
    });

    group('addProductToCart', () {
      test('should add product to cart successfully', () async {
        final result = await cartService.addProductToCart(testProduct);
        expect(result, true);

        final items = await cartService.getCartItems();
        expect(items, hasLength(1));
        expect(items[0].product.id, 1);
        expect(items[0].quantity, 1);
      });

      test('should add product with custom quantity', () async {
        final result =
            await cartService.addProductToCart(testProduct, quantity: 3);
        expect(result, true);

        final items = await cartService.getCartItems();
        expect(items, hasLength(1));
        expect(items[0].quantity, 3);
      });

      test('should update quantity when product already exists', () async {
        await cartService.addProductToCart(testProduct, quantity: 2);
        final result =
            await cartService.addProductToCart(testProduct, quantity: 3);

        expect(result, true);

        final items = await cartService.getCartItems();
        expect(items, hasLength(1));
        expect(items[0].quantity, 5); // 2 + 3
      });
    });

    group('getCartItems', () {
      test('should return empty list when cart is empty', () async {
        final result = await cartService.getCartItems();
        expect(result, isEmpty);
      });

      test('should return list of cart items', () async {
        await cartService.addProductToCart(testProduct, quantity: 2);

        final result = await cartService.getCartItems();
        expect(result, hasLength(1));
        expect(result[0].product.id, 1);
        expect(result[0].quantity, 2);
      });
    });

    group('getCartItemCount', () {
      test('should return 0 when cart is empty', () async {
        final result = await cartService.getCartItemCount();
        expect(result, 0);
      });

      test('should return total quantity of all items', () async {
        await cartService.addProductToCart(testProduct, quantity: 2);

        const product2 = Product(
          id: 2,
          title: 'Product 2',
          description: 'Description 2',
          price: 50.0,
          image: 'image2.jpg',
          category: 'books',
          rating: Rating(rate: 3.5, count: 25),
        );
        await cartService.addProductToCart(product2, quantity: 3);

        final result = await cartService.getCartItemCount();
        expect(result, 5); // 2 + 3
      });
    });

    group('getCartTotal', () {
      test('should return 0.0 when cart is empty', () async {
        final result = await cartService.getCartTotal();
        expect(result, 0.0);
      });

      test('should return correct total price', () async {
        await cartService.addProductToCart(testProduct, quantity: 2);

        final result = await cartService.getCartTotal();
        expect(result,
            20.0); // Mock product has price 10.0 * id = 10.0 * 1 = 10.0, quantity 2 = 20.0
      });
    });

    group('isProductInCart', () {
      test('should return false when product not in cart', () async {
        final result = await cartService.isProductInCart(1);
        expect(result, false);
      });

      test('should return true when product is in cart', () async {
        await cartService.addProductToCart(testProduct);

        final result = await cartService.isProductInCart(1);
        expect(result, true);
      });
    });

    group('clearCart', () {
      test('should clear all items from cart', () async {
        await cartService.addProductToCart(testProduct, quantity: 2);

        final result = await cartService.clearCart();
        expect(result, true);

        final items = await cartService.getCartItems();
        expect(items, isEmpty);
      });
    });
  });
}
