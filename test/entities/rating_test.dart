import 'package:flutter_ecommerce/entities/rating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rating Entity Tests', () {
    test('should create a Rating with all required fields', () {
      const rating = Rating(rate: 4.5, count: 100);

      expect(rating.rate, 4.5);
      expect(rating.count, 100);
    });

    test('should create Rating from JSON correctly', () {
      final json = {'rate': 4.5, 'count': 100};

      final rating = Rating.fromJson(json);

      expect(rating.rate, 4.5);
      expect(rating.count, 100);
    });

    test('should handle invalid JSON gracefully', () {
      final json = <String, dynamic>{};

      final rating = Rating.fromJson(json);

      expect(rating.rate, 0.0);
      expect(rating.count, 0);
    });

    test('should handle null values in JSON', () {
      final json = {'rate': null, 'count': null};

      final rating = Rating.fromJson(json);

      expect(rating.rate, 0.0);
      expect(rating.count, 0);
    });

    test('should handle rate as int in JSON', () {
      final json = {
        'rate': 4, // int instead of double
        'count': 100,
      };

      final rating = Rating.fromJson(json);

      expect(rating.rate, 4.0);
      expect(rating.count, 100);
    });

    test('should convert to JSON correctly', () {
      const rating = Rating(rate: 4.5, count: 100);
      final json = rating.toJson();

      expect(json['rate'], 4.5);
      expect(json['count'], 100);
    });

    test('should support equality comparison', () {
      const rating1 = Rating(rate: 4.5, count: 100);
      const rating2 = Rating(rate: 4.5, count: 100);
      const rating3 = Rating(rate: 3.5, count: 100);

      expect(rating1, equals(rating2));
      expect(rating1, isNot(equals(rating3)));
    });

    test('should have proper string representation', () {
      const rating = Rating(rate: 4.5, count: 100);
      final stringRepresentation = rating.toString();

      expect(stringRepresentation, contains('4.5'));
      expect(stringRepresentation, contains('100'));
    });
  });
}
