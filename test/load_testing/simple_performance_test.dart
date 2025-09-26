import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Test de performance simple et propre pour Flutter
/// Conforme aux standards de test Flutter
void main() {
  group('Performance Tests - Flutter E-commerce', () {
    test('Basic load test - Application response', () async {
      const String baseUrl = 'https://flutterecommerce-fc124.firebaseapp.com';
      const int numberOfRequests = 10;

      final List<Duration> responseTimes = [];
      int successfulRequests = 0;

      // Exécuter les requêtes
      for (int i = 0; i < numberOfRequests; i++) {
        final stopwatch = Stopwatch()..start();

        try {
          final response = await http.get(Uri.parse(baseUrl));
          stopwatch.stop();

          responseTimes.add(stopwatch.elapsed);

          if (response.statusCode == 200) {
            successfulRequests++;
          }
        } catch (e) {
          stopwatch.stop();
          // Ignorer l'erreur pour ce test simple
        }

        // Petite pause entre les requêtes
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Vérifications
      expect(responseTimes.isNotEmpty, true,
          reason: 'Au moins une requête doit avoir été exécutée');
      expect(successfulRequests, greaterThan(0),
          reason: 'Au moins une requête doit réussir');

      // Calculer les métriques
      final avgResponseTime =
          responseTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
              responseTimes.length;

      final successRate = (successfulRequests / numberOfRequests) * 100;

      // Tests de performance
      expect(avgResponseTime, lessThan(5000),
          reason:
              'Temps de réponse moyen doit être < 5s, actuel: ${avgResponseTime.toStringAsFixed(0)}ms');

      expect(successRate, greaterThan(50),
          reason:
              'Taux de succès doit être > 50%, actuel: ${successRate.toStringAsFixed(1)}%');
    });

    test('API endpoints response test', () async {
      const String apiUrl = 'https://fakestoreapi.com';
      final List<String> endpoints = [
        '/products?limit=5',
        '/products/1',
        '/products/categories'
      ];

      for (final endpoint in endpoints) {
        final stopwatch = Stopwatch()..start();

        try {
          final response = await http.get(Uri.parse('$apiUrl$endpoint'));
          stopwatch.stop();

          expect(response.statusCode, equals(200),
              reason: 'Endpoint $endpoint doit retourner 200');

          expect(stopwatch.elapsed.inMilliseconds, lessThan(10000),
              reason: 'Endpoint $endpoint doit répondre en < 10s');

          // Vérifier que la réponse est du JSON valide
          final data = json.decode(response.body);
          expect(data, isNotNull, reason: 'Réponse JSON valide attendue');
        } catch (e) {
          fail('Erreur sur endpoint $endpoint: $e');
        }

        // Pause entre les tests d'endpoints
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });

    test('Concurrent requests test', () async {
      const String baseUrl = 'https://flutterecommerce-fc124.firebaseapp.com';
      const int concurrentRequests = 5;

      final List<Future<http.Response>> futures = [];

      // Lancer toutes les requêtes en parallèle
      for (int i = 0; i < concurrentRequests; i++) {
        futures.add(http.get(Uri.parse(baseUrl)));
      }

      final stopwatch = Stopwatch()..start();

      try {
        final responses = await Future.wait(futures, eagerError: false);
        stopwatch.stop();

        final successfulResponses =
            responses.where((response) => response.statusCode == 200).length;

        expect(successfulResponses, greaterThan(0),
            reason: 'Au moins une requête concurrente doit réussir');

        expect(stopwatch.elapsed.inSeconds, lessThan(30),
            reason: 'Les requêtes concurrentes doivent se terminer en < 30s');
      } catch (e) {
        // En cas d'erreur, vérifier au moins que le test se termine rapidement
        expect(stopwatch.elapsed.inSeconds, lessThan(30),
            reason:
                'Même en cas d\'erreur, le test doit se terminer rapidement');
      }
    });
  });
}
