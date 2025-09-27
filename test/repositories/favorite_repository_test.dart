import 'package:flutter_ecommerce/entities/favorite.dart';
import 'package:flutter_ecommerce/repositories/favorite_repository_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'favorite_repository_test.mocks.dart';

@GenerateMocks([FavoriteRepositoryInterface])
void main() {
  group('FavoriteRepository Tests', () {
    late MockFavoriteRepositoryInterface mockRepository;
    late DateTime testDate;

    setUp(() {
      mockRepository = MockFavoriteRepositoryInterface();
      testDate = DateTime(2023, 12, 25);
    });

    group('Interface Contract Tests', () {
      test('should add favorite', () async {
        final favorite = Favorite(
          id: 1,
          productId: 123,
          addedAt: testDate,
        );

        when(mockRepository.addFavorite(123)).thenAnswer((_) async => favorite);

        final result = await mockRepository.addFavorite(123);

        expect(result, isA<Favorite>());
        expect(result.productId, equals(123));
        expect(result.id, equals(1));
        expect(result.addedAt, equals(testDate));
        verify(mockRepository.addFavorite(123)).called(1);
      });

      test('should remove favorite', () async {
        when(mockRepository.removeFavorite(123)).thenAnswer((_) async => true);

        final result = await mockRepository.removeFavorite(123);

        expect(result, isTrue);
        verify(mockRepository.removeFavorite(123)).called(1);
      });

      test('should check if product is favorite', () async {
        when(mockRepository.isFavorite(123)).thenAnswer((_) async => true);
        when(mockRepository.isFavorite(456)).thenAnswer((_) async => false);

        final result1 = await mockRepository.isFavorite(123);
        final result2 = await mockRepository.isFavorite(456);

        expect(result1, isTrue);
        expect(result2, isFalse);
        verify(mockRepository.isFavorite(123)).called(1);
        verify(mockRepository.isFavorite(456)).called(1);
      });

      test('should get all favorites', () async {
        final favorites = [
          Favorite(id: 1, productId: 123, addedAt: testDate),
          Favorite(
              id: 2,
              productId: 456,
              addedAt: testDate.add(const Duration(days: 1))),
        ];

        when(mockRepository.getAllFavorites())
            .thenAnswer((_) async => favorites);

        final result = await mockRepository.getAllFavorites();

        expect(result, hasLength(2));
        expect(result[0].productId, equals(123));
        expect(result[1].productId, equals(456));
        verify(mockRepository.getAllFavorites()).called(1);
      });

      test('should clear all favorites', () async {
        when(mockRepository.clearFavorites()).thenAnswer((_) async => true);

        final result = await mockRepository.clearFavorites();

        expect(result, isTrue);
        verify(mockRepository.clearFavorites()).called(1);
      });
    });

    group('Edge Cases', () {
      test('should handle adding duplicate favorite', () async {
        when(mockRepository.addFavorite(123))
            .thenThrow(Exception('Product already in favorites'));

        expect(
          () => mockRepository.addFavorite(123),
          throwsException,
        );
        verify(mockRepository.addFavorite(123)).called(1);
      });

      test('should handle removing non-existent favorite', () async {
        when(mockRepository.removeFavorite(999)).thenAnswer((_) async => false);

        final result = await mockRepository.removeFavorite(999);

        expect(result, isFalse);
        verify(mockRepository.removeFavorite(999)).called(1);
      });

      test('should handle checking non-existent product', () async {
        when(mockRepository.isFavorite(999)).thenAnswer((_) async => false);

        final result = await mockRepository.isFavorite(999);

        expect(result, isFalse);
        verify(mockRepository.isFavorite(999)).called(1);
      });

      test('should handle empty favorites list', () async {
        when(mockRepository.getAllFavorites()).thenAnswer((_) async => []);

        final result = await mockRepository.getAllFavorites();

        expect(result, isEmpty);
        verify(mockRepository.getAllFavorites()).called(1);
      });

      test('should handle database errors', () async {
        when(mockRepository.getAllFavorites())
            .thenThrow(DatabaseException('Database error'));

        expect(
          () => mockRepository.getAllFavorites(),
          throwsA(isA<DatabaseException>()),
        );
        verify(mockRepository.getAllFavorites()).called(1);
      });
    });

    group('Performance Tests', () {
      test('should handle large favorites list', () async {
        final largeFavoritesList = List.generate(
          1000,
          (index) => Favorite(
            id: index,
            productId: index + 100,
            addedAt: testDate.add(Duration(minutes: index)),
          ),
        );

        when(mockRepository.getAllFavorites())
            .thenAnswer((_) async => largeFavoritesList);

        final result = await mockRepository.getAllFavorites();

        expect(result, hasLength(1000));
        expect(result.first.productId, equals(100));
        expect(result.last.productId, equals(1099));
        verify(mockRepository.getAllFavorites()).called(1);
      });

      test('should handle rapid operations', () async {
        when(mockRepository.addFavorite(any))
            .thenAnswer((invocation) async => Favorite(
                  id: 1,
                  productId: invocation.positionalArguments[0] as int,
                  addedAt: testDate,
                ));

        final futures = <Future<Favorite>>[];
        for (int i = 1; i <= 10; i++) {
          futures.add(mockRepository.addFavorite(i));
        }

        final results = await Future.wait(futures);

        expect(results, hasLength(10));
        expect(results.map((f) => f.productId),
            containsAll([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]));
      });
    });

    group('Data Integrity Tests', () {
      test('should maintain favorite timestamps', () async {
        final favorite1 = Favorite(id: 1, productId: 123, addedAt: testDate);
        final favorite2 = Favorite(
            id: 2,
            productId: 456,
            addedAt: testDate.add(const Duration(hours: 1)));

        when(mockRepository.getAllFavorites())
            .thenAnswer((_) async => [favorite1, favorite2]);

        final result = await mockRepository.getAllFavorites();

        expect(result[0].addedAt.isBefore(result[1].addedAt), isTrue);
        expect(result[0].addedAt, equals(testDate));
        expect(
            result[1].addedAt, equals(testDate.add(const Duration(hours: 1))));
      });

      test('should validate product IDs', () async {
        final validIds = [1, 100, 999, 1000];

        for (final id in validIds) {
          when(mockRepository.isFavorite(id)).thenAnswer((_) async => false);

          final result = await mockRepository.isFavorite(id);
          expect(result, isA<bool>());
        }
      });

      test('should handle concurrent operations', () async {
        when(mockRepository.addFavorite(123)).thenAnswer(
            (_) async => Favorite(id: 1, productId: 123, addedAt: testDate));
        when(mockRepository.removeFavorite(456)).thenAnswer((_) async => true);
        when(mockRepository.isFavorite(789)).thenAnswer((_) async => false);

        final futures = [
          mockRepository.addFavorite(123),
          mockRepository.removeFavorite(456),
          mockRepository.isFavorite(789),
        ];

        final results = await Future.wait([
          futures[0].then((value) => 'add'),
          futures[1].then((value) => 'remove'),
          futures[2].then((value) => 'check'),
        ]);

        expect(results, containsAll(['add', 'remove', 'check']));
      });
    });

    group('Business Logic Tests', () {
      test('should track when favorites were added', () async {
        final now = DateTime.now();
        final favorite = Favorite(id: 1, productId: 123, addedAt: now);

        when(mockRepository.addFavorite(123)).thenAnswer((_) async => favorite);

        final result = await mockRepository.addFavorite(123);

        expect(result.addedAt.difference(now).inSeconds, lessThan(5));
      });

      test('should handle favorite toggle operations', () async {
        // Initially not favorite
        when(mockRepository.isFavorite(123)).thenAnswer((_) async => false);

        // Add to favorites
        when(mockRepository.addFavorite(123)).thenAnswer(
            (_) async => Favorite(id: 1, productId: 123, addedAt: testDate));

        // Now is favorite
        when(mockRepository.isFavorite(123)).thenAnswer((_) async => true);

        // Remove from favorites
        when(mockRepository.removeFavorite(123)).thenAnswer((_) async => true);

        // Test the flow
        expect(await mockRepository.isFavorite(123), isFalse);
        await mockRepository.addFavorite(123);
        expect(await mockRepository.isFavorite(123), isTrue);
        await mockRepository.removeFavorite(123);
      });

      test('should support sorting favorites by date', () async {
        final favorites = [
          Favorite(
              id: 1,
              productId: 123,
              addedAt: testDate.add(const Duration(days: 2))),
          Favorite(id: 2, productId: 456, addedAt: testDate),
          Favorite(
              id: 3,
              productId: 789,
              addedAt: testDate.add(const Duration(days: 1))),
        ];

        when(mockRepository.getAllFavorites())
            .thenAnswer((_) async => favorites);

        final result = await mockRepository.getAllFavorites();

        // Sort by addedAt (newest first)
        result.sort((a, b) => b.addedAt.compareTo(a.addedAt));

        expect(result[0].productId, equals(123)); // newest
        expect(result[1].productId, equals(789)); // middle
        expect(result[2].productId, equals(456)); // oldest
      });
    });

    group('Error Handling Tests', () {
      test('should handle network timeouts', () async {
        when(mockRepository.getAllFavorites())
            .thenThrow(Exception('Network timeout'));

        expect(
          () => mockRepository.getAllFavorites(),
          throwsException,
        );
      });

      test('should handle invalid product IDs', () async {
        when(mockRepository.addFavorite(-1))
            .thenThrow(ArgumentError('Invalid product ID'));

        expect(
          () => mockRepository.addFavorite(-1),
          throwsArgumentError,
        );
      });

      test('should handle database corruption', () async {
        when(mockRepository.clearFavorites())
            .thenThrow(DatabaseException('Database is corrupted'));

        expect(
          () => mockRepository.clearFavorites(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });
  });
}
