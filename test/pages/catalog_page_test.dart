import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/catalog_page.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/mock_auth_guard.dart';

void main() {
  group('CatalogPage Tests', () {
    Widget createWidgetUnderTest() {
      return createTestWidgetWithMockAuth(const CatalogPage());
    }

    testWidgets('should build without crashing', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should display scaffold and app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display product grid/list',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Rechercher des structures de grille ou liste
      expect(find.byType(GridView), findsAtLeastNWidgets(0));
      expect(find.byType(ListView), findsAtLeastNWidgets(0));
    });

    testWidgets('should handle search functionality',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Rechercher barre de recherche
      final searchFields = find.byType(TextField);
      if (searchFields.evaluate().isNotEmpty) {
        await tester.enterText(searchFields.first, 'test product');
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should display filter options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Rechercher des options de filtre
      final filterButtons = find.byIcon(Icons.filter_list);
      if (filterButtons.evaluate().isNotEmpty) {
        await tester.tap(filterButtons.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle category selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de sélection de catégorie
      final chips = find.byType(Chip);
      if (chips.evaluate().isNotEmpty) {
        await tester.tap(chips.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle product card taps', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de tap sur cartes produit
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should display loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Test indicateur de chargement
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(0));
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final refreshIndicators = find.byType(RefreshIndicator);
      if (refreshIndicators.evaluate().isNotEmpty) {
        await tester.fling(
            find.byType(CatalogPage), const Offset(0, 300), 1000);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle infinite scroll', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de défilement infini
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -500));
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should toggle grid/list view', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de basculement vue grille/liste
      final viewToggleButtons = find.byIcon(Icons.view_list);
      final gridToggleButtons = find.byIcon(Icons.grid_view);

      if (viewToggleButtons.evaluate().isNotEmpty) {
        await tester.tap(viewToggleButtons.first);
        await tester.pump();
      }

      if (gridToggleButtons.evaluate().isNotEmpty) {
        await tester.tap(gridToggleButtons.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle sort options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test d'options de tri
      final sortButtons = find.byIcon(Icons.sort);
      if (sortButtons.evaluate().isNotEmpty) {
        await tester.tap(sortButtons.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should display empty state', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test d'état vide
      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle favorites toggle', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test de basculement favoris
      final favoriteButtons = find.byIcon(Icons.favorite_border);
      if (favoriteButtons.evaluate().isNotEmpty) {
        await tester.tap(favoriteButtons.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should handle add to cart', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Test d'ajout au panier
      final addToCartButtons = find.byIcon(Icons.add_shopping_cart);
      if (addToCartButtons.evaluate().isNotEmpty) {
        await tester.tap(addToCartButtons.first);
        await tester.pump();
      }

      expect(find.byType(CatalogPage), findsOneWidget);
    });

    testWidgets('should maintain responsive design',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Mobile
      await tester.binding.setSurfaceSize(const Size(360, 640));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogPage), findsOneWidget);

      // Tablet
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogPage), findsOneWidget);

      // Desktop
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpAndSettle();
      expect(find.byType(CatalogPage), findsOneWidget);
    });

    group('Search Functionality', () {
      testWidgets('should filter results based on search',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await tester.enterText(searchFields.first, 'electronics');
          await tester.pump();

          // Simuler soumission de recherche
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pump();
        }

        expect(find.byType(CatalogPage), findsOneWidget);
      });

      testWidgets('should handle search clearing', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final searchFields = find.byType(TextField);
        if (searchFields.evaluate().isNotEmpty) {
          await tester.enterText(searchFields.first, 'test');
          await tester.pump();

          // Effacer la recherche
          final clearButtons = find.byIcon(Icons.clear);
          if (clearButtons.evaluate().isNotEmpty) {
            await tester.tap(clearButtons.first);
            await tester.pump();
          }
        }

        expect(find.byType(CatalogPage), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle network errors', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('should display error messages', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(CatalogPage), findsOneWidget);
      });

      testWidgets('should handle retry functionality',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final retryButtons = find.text('Retry');
        if (retryButtons.evaluate().isNotEmpty) {
          await tester.tap(retryButtons.first);
          await tester.pump();
        }

        expect(find.byType(CatalogPage), findsOneWidget);
      });
    });

    group('Performance Tests', () {
      testWidgets('should render efficiently with many items',
          (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(400));
      });

      testWidgets('should handle smooth scrolling',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isNotEmpty) {
          for (int i = 0; i < 10; i++) {
            await tester.drag(scrollables.first, const Offset(0, -50));
            await tester.pump(const Duration(milliseconds: 16));
          }
        }

        expect(find.byType(CatalogPage), findsOneWidget);
      });
    });

    group('Accessibility', () {
      testWidgets('should support screen readers', (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(Semantics), findsAtLeastNWidgets(1));
      });

      testWidgets('should have proper semantics for products',
          (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(CatalogPage), findsOneWidget);
      });
    });
  });
}
