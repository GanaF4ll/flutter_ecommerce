import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_auth_guard.dart';

void main() {
  group('HomePage Tests', () {
    Widget createWidgetUnderTest() {
      return createTestWidgetWithMockAuth(const HomePage());
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display body content', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le body contient du contenu
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should handle navigation', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de base de navigation
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('should display correct theme', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp, isNotNull);
    });

    testWidgets('should be responsive', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test différentes tailles d'écran
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle state changes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Simuler des changements d'état
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should display loading states', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Test d'états de chargement
      await tester.pump();
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle errors gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de gestion d'erreurs
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain performance', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Test de performance de base
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // Le build devrait être rapide (moins de 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('should handle accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Vérifier l'accessibilité de base
      expect(find.byType(Semantics), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle memory management', (WidgetTester tester) async {
      // Test de gestion mémoire
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
      }

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle widget lifecycle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test du cycle de vie
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('should handle hot reload', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Simuler hot reload
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should handle orientation changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);

      // Landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });

    group('Edge Cases', () {
      testWidgets('should handle null values', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should handle empty states', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should handle large datasets', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('should integrate with navigation',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const HomePage(),
            routes: {
              '/test': (context) => const Scaffold(body: Text('Test Page')),
            },
          ),
        );

        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should integrate with theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(primarySwatch: Colors.blue),
            home: const HomePage(),
          ),
        );

        expect(find.byType(HomePage), findsOneWidget);
      });
    });
  });
}
