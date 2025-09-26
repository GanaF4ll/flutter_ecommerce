import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math';

/// Test de montée en charge natif Flutter
/// Utilise les tests d'intégration Flutter sans outils externes
void main() {
  group('Tests de montée en charge Flutter E-commerce', () {
    late List<Duration> responseTimes;
    late List<bool> successfulRequests;

    setUp(() {
      responseTimes = [];
      successfulRequests = [];
    });

    testWidgets('Test de charge de base - Application web',
        (WidgetTester tester) async {
      const String baseUrl = 'https://flutterecommerce-fc124.firebaseapp.com';
      const int numberOfRequests = 50;
      const int concurrentUsers = 5;

      print('🚀 Démarrage du test de charge Flutter natif');
      print('URL cible: $baseUrl');
      print('Requêtes: $numberOfRequests');
      print('Utilisateurs concurrents: $concurrentUsers');

      // Test de montée en charge
      final List<Future<void>> futures = [];

      for (int i = 0; i < concurrentUsers; i++) {
        futures.add(_simulateUserSession(
            baseUrl, numberOfRequests ~/ concurrentUsers, i));
      }

      final stopwatch = Stopwatch()..start();
      await Future.wait(futures);
      stopwatch.stop();

      // Analyse des résultats
      _analyzeResults(stopwatch.elapsed, numberOfRequests);
    });

    testWidgets('Test API FakeStore', (WidgetTester tester) async {
      const String apiUrl = 'https://fakestoreapi.com';
      const int requests = 20;

      print('🔌 Test API FakeStore');

      final futures = <Future<void>>[];
      for (int i = 0; i < requests; i++) {
        futures.add(_testApiEndpoint(apiUrl));
      }

      await Future.wait(futures);
      _analyzeResults(Duration(seconds: 1), requests);
    });

    testWidgets('Test de stress progressif', (WidgetTester tester) async {
      const String baseUrl = 'https://flutterecommerce-fc124.firebaseapp.com';

      print('⚡ Test de stress progressif');

      // Phase 1: 5 utilisateurs
      await _stressPhase(baseUrl, 5, 'Phase 1: Charge légère');

      // Phase 2: 15 utilisateurs
      await _stressPhase(baseUrl, 15, 'Phase 2: Charge modérée');

      // Phase 3: 30 utilisateurs
      await _stressPhase(baseUrl, 30, 'Phase 3: Charge élevée');

      _generateReport();
    });
  });
}

/// Simule une session utilisateur complète
Future<void> _simulateUserSession(
    String baseUrl, int requestsPerUser, int userId) async {
  final client = http.Client();
  final random = Random();

  try {
    for (int i = 0; i < requestsPerUser; i++) {
      final stopwatch = Stopwatch()..start();

      // Simuler différentes actions utilisateur
      final action = random.nextInt(4);
      late http.Response response;

      switch (action) {
        case 0:
          // Page d'accueil
          response = await client.get(Uri.parse('$baseUrl/'));
          break;
        case 1:
          // Catalogue
          response = await client.get(Uri.parse('$baseUrl/#/catalog'));
          break;
        case 2:
          // Produit aléatoire
          final productId = random.nextInt(20) + 1;
          response =
              await client.get(Uri.parse('$baseUrl/#/product/$productId'));
          break;
        case 3:
          // Recherche
          final searchTerm =
              ['smartphone', 'ordinateur', 'casque'][random.nextInt(3)];
          response = await client
              .get(Uri.parse('$baseUrl/#/catalog?search=$searchTerm'));
          break;
      }

      stopwatch.stop();
      responseTimes.add(stopwatch.elapsed);
      successfulRequests.add(response.statusCode == 200);

      // Pause réaliste entre les requêtes
      await Future.delayed(Duration(milliseconds: 500 + random.nextInt(1000)));
    }
  } catch (e) {
    print('❌ Erreur utilisateur $userId: $e');
  } finally {
    client.close();
  }
}

/// Test des endpoints API
Future<void> _testApiEndpoint(String apiUrl) async {
  final client = http.Client();
  final random = Random();

  try {
    final stopwatch = Stopwatch()..start();

    // Tester différents endpoints
    final endpoints = [
      '/products',
      '/products/1',
      '/products/categories',
      '/products/category/electronics'
    ];

    final endpoint = endpoints[random.nextInt(endpoints.length)];
    final response = await client.get(Uri.parse('$apiUrl$endpoint'));

    stopwatch.stop();
    responseTimes.add(stopwatch.elapsed);
    successfulRequests.add(response.statusCode == 200);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ API $endpoint: ${data.toString().length} chars');
    }
  } catch (e) {
    print('❌ Erreur API: $e');
    successfulRequests.add(false);
  } finally {
    client.close();
  }
}

/// Phase de test de stress
Future<void> _stressPhase(String baseUrl, int users, String phaseName) async {
  print('📊 $phaseName ($users utilisateurs)');

  final futures = <Future<void>>[];
  for (int i = 0; i < users; i++) {
    futures.add(_simulateUserSession(baseUrl, 3, i));
  }

  final stopwatch = Stopwatch()..start();
  await Future.wait(futures);
  stopwatch.stop();

  print('   ⏱️ Durée: ${stopwatch.elapsed.inSeconds}s');
  print(
      '   📈 Requêtes/sec: ${(users * 3 / stopwatch.elapsed.inSeconds).toStringAsFixed(1)}');
}

/// Analyse et affichage des résultats
void _analyzeResults(Duration totalDuration, int totalRequests) {
  if (responseTimes.isEmpty) {
    print('❌ Aucune donnée de performance collectée');
    return;
  }

  // Calculs statistiques
  responseTimes.sort();
  final avgResponseTime =
      responseTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
          responseTimes.length;
  final p50 = responseTimes[responseTimes.length ~/ 2].inMilliseconds;
  final p95 =
      responseTimes[(responseTimes.length * 0.95).round() - 1].inMilliseconds;
  final maxResponseTime = responseTimes.last.inMilliseconds;

  final successRate = successfulRequests.where((s) => s).length /
      successfulRequests.length *
      100;
  final requestsPerSecond = totalRequests / totalDuration.inSeconds;

  print('\n📊 === RÉSULTATS DU TEST ===');
  print('⏱️  Durée totale: ${totalDuration.inSeconds}s');
  print('🔢 Requêtes totales: $totalRequests');
  print('📈 Débit: ${requestsPerSecond.toStringAsFixed(1)} req/s');
  print('✅ Taux de succès: ${successRate.toStringAsFixed(1)}%');
  print('\n⏱️  TEMPS DE RÉPONSE:');
  print('   Moyenne: ${avgResponseTime.toStringAsFixed(0)}ms');
  print('   P50 (médiane): ${p50}ms');
  print('   P95: ${p95}ms');
  print('   Maximum: ${maxResponseTime}ms');

  // Évaluation de la performance
  print('\n🎯 ÉVALUATION:');
  if (avgResponseTime < 1000) {
    print('   🚀 Performance excellente');
  } else if (avgResponseTime < 2000) {
    print('   👍 Performance correcte');
  } else {
    print('   ⚠️  Performance à améliorer');
  }

  if (successRate > 95) {
    print('   ✅ Fiabilité excellente');
  } else if (successRate > 90) {
    print('   👍 Fiabilité correcte');
  } else {
    print('   ❌ Problèmes de fiabilité détectés');
  }

  print('================================\n');
}

/// Génération d'un rapport final
void _generateReport() {
  print('\n📋 === RAPPORT FINAL ===');
  print('Tests de montée en charge terminés');
  print('Application: Flutter E-commerce');
  print('Date: ${DateTime.now()}');
  print('Mode: Tests d\'intégration Flutter natifs');
  print('========================\n');
}
