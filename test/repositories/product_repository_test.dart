import 'dart:convert';
import 'package:flutter_ecommerce/entities/product.dart';
import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_ecommerce/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductRepository Tests', () {
    late ProductRepository productRepository;

    setUp(() {
      productRepository = ProductRepository();
    });

    test('should create ProductRepository instance', () {
      expect(productRepository, isNotNull);
      expect(productRepository, isA<ProductRepository>());
    });

    group('JSON parsing and data handling', () {
      test('should parse product from JSON correctly', () {
        const mockProductJson = '''
        {
          "id": 1,
          "title": "Test Product",
          "description": "Test Description",
          "price": 99.99,
          "image": "https://example.com/image.jpg",
          "category": "electronics",
          "rating": {"rate": 4.5, "count": 100}
        }
        ''';

        final jsonData = json.decode(mockProductJson);
        final product = Product.fromJson(jsonData);

        expect(product.id, 1);
        expect(product.title, 'Test Product');
        expect(product.price, 99.99);
        expect(product.category, 'electronics');
        expect(product.rating.rate, 4.5);
      });

      test('should handle array of products', () {
        const mockProductsJson = '''
        {
          "products": [
            {
              "id": 1,
              "title": "Product 1",
              "description": "Description 1",
              "price": 50.0,
              "image": "image1.jpg",
              "category": "books",
              "rating": {"rate": 4.0, "count": 25}
            },
            {
              "id": 2,
              "title": "Product 2",
              "description": "Description 2", 
              "price": 75.0,
              "image": "image2.jpg",
              "category": "electronics",
              "rating": {"rate": 4.5, "count": 50}
            }
          ]
        }
        ''';

        final jsonData = json.decode(mockProductsJson);
        final productsData = jsonData['products'] as List<dynamic>;
        final products =
            productsData.map((json) => Product.fromJson(json)).toList();

        expect(products, hasLength(2));
        expect(products[0].title, 'Product 1');
        expect(products[1].title, 'Product 2');
        expect(products[0].category, 'books');
        expect(products[1].category, 'electronics');
      });

      test('should filter products by category', () {
        final mockProducts = [
          const Product(
            id: 1,
            title: 'Phone',
            description: 'Smartphone',
            price: 500.0,
            image: 'phone.jpg',
            category: 'electronics',
            rating: Rating(rate: 4.5, count: 100),
          ),
          const Product(
            id: 2,
            title: 'Book',
            description: 'Novel',
            price: 20.0,
            image: 'book.jpg',
            category: 'books',
            rating: Rating(rate: 4.0, count: 50),
          ),
          const Product(
            id: 3,
            title: 'Laptop',
            description: 'Computer',
            price: 1000.0,
            image: 'laptop.jpg',
            category: 'electronics',
            rating: Rating(rate: 4.8, count: 200),
          ),
        ];

        final electronicsProducts = mockProducts
            .where((product) => product.category == 'electronics')
            .toList();

        expect(electronicsProducts, hasLength(2));
        expect(electronicsProducts[0].title, 'Phone');
        expect(electronicsProducts[1].title, 'Laptop');
      });

      test('should find product by ID', () {
        final mockProducts = [
          const Product(
            id: 1,
            title: 'Product 1',
            description: 'Description 1',
            price: 100.0,
            image: 'image1.jpg',
            category: 'category1',
            rating: Rating(rate: 4.0, count: 10),
          ),
          const Product(
            id: 2,
            title: 'Product 2',
            description: 'Description 2',
            price: 200.0,
            image: 'image2.jpg',
            category: 'category2',
            rating: Rating(rate: 4.5, count: 20),
          ),
        ];

        final foundProduct = mockProducts.where((p) => p.id == 2).first;

        expect(foundProduct.id, 2);
        expect(foundProduct.title, 'Product 2');
        expect(foundProduct.price, 200.0);
      });

      test('should handle empty product list', () {
        const List<Product> emptyProducts = [];

        expect(emptyProducts, isEmpty);

        final electronicsProducts = emptyProducts
            .where((product) => product.category == 'electronics')
            .toList();

        expect(electronicsProducts, isEmpty);
      });

      test('should handle product with minimum data', () {
        const mockProductJson = '''
        {
          "id": 1,
          "title": "Minimal Product",
          "description": "",
          "price": 0.0,
          "image": "",
          "category": "",
          "rating": {"rate": 0.0, "count": 0}
        }
        ''';

        final jsonData = json.decode(mockProductJson);
        final product = Product.fromJson(jsonData);

        expect(product.id, 1);
        expect(product.title, 'Minimal Product');
        expect(product.price, 0.0);
        expect(product.rating.rate, 0.0);
      });

      test('should sort products by price', () {
        final mockProducts = [
          const Product(
            id: 1,
            title: 'Expensive',
            description: 'Desc',
            price: 500.0,
            image: 'img1.jpg',
            category: 'cat',
            rating: Rating(rate: 4.0, count: 10),
          ),
          const Product(
            id: 2,
            title: 'Cheap',
            description: 'Desc',
            price: 50.0,
            image: 'img2.jpg',
            category: 'cat',
            rating: Rating(rate: 4.0, count: 10),
          ),
          const Product(
            id: 3,
            title: 'Medium',
            description: 'Desc',
            price: 200.0,
            image: 'img3.jpg',
            category: 'cat',
            rating: Rating(rate: 4.0, count: 10),
          ),
        ];

        final sortedProducts = List.from(mockProducts)
          ..sort((a, b) => a.price.compareTo(b.price));

        expect(sortedProducts[0].title, 'Cheap');
        expect(sortedProducts[1].title, 'Medium');
        expect(sortedProducts[2].title, 'Expensive');
      });

      test('should handle duplicate products correctly', () {
        final mockProducts = [
          const Product(
            id: 1,
            title: 'Product A',
            description: 'Desc',
            price: 100.0,
            image: 'img.jpg',
            category: 'cat',
            rating: Rating(rate: 4.0, count: 10),
          ),
          const Product(
            id: 1,
            title: 'Product A',
            description: 'Desc',
            price: 100.0,
            image: 'img.jpg',
            category: 'cat',
            rating: Rating(rate: 4.0, count: 10),
          ),
        ];

        // Test que les produits avec le même ID sont considérés comme égaux
        expect(mockProducts[0] == mockProducts[1], true);

        // Supprimer les doublons basés sur l'ID
        final uniqueProducts =
            mockProducts.fold<List<Product>>([], (list, product) {
          if (!list.any((p) => p.id == product.id)) {
            list.add(product);
          }
          return list;
        });

        expect(uniqueProducts, hasLength(1));
      });
    });

    group('Repository methods validation', () {
      test('fetchLocalProducts should return Future<List<Product>>', () {
        expect(productRepository.fetchLocalProducts(),
            isA<Future<List<Product>>>());
      });

      test('fetchLocalProductById should return Future<Product>', () {
        expect(productRepository.fetchLocalProductById('1'),
            isA<Future<Product>>());
      });

      test('fetchLocalProductsByCategory should return Future<List<Product>>',
          () {
        expect(productRepository.fetchLocalProductsByCategory('electronics'),
            isA<Future<List<Product>>>());
      });

      test('fetchProducts should return Future<List<Product>>', () {
        expect(productRepository.fetchProducts(), isA<Future<List<Product>>>());
      });

      test('fetchProductById should return Future<Product>', () {
        expect(productRepository.fetchProductById('1'), isA<Future<Product>>());
      });
    });
  });
}
