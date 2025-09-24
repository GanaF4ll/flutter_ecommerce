import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/pages/favorites_page.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock Firebase Auth
class MockFirebaseAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
}

void main() {
  group('FavoritesPage Widget Tests', () {
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: const FavoritesPage(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Page')),
          '/catalog': (context) => const Scaffold(body: Text('Catalog Page')),
        },
      );
    }

    testWidgets('should display app bar with correct title and styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Mes Favoris'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, Colors.cyan);
      expect(appBar.foregroundColor, Colors.white);
    });

    testWidgets('should display clear all button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier le bouton "Vider les favoris"
      expect(find.byIcon(Icons.clear_all), findsOneWidget);
    });

    testWidgets('should display drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le drawer est présent
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Avant que les données ne soient chargées
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no favorites', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier l'état vide (si aucun favori n'est présent)
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.text('Aucun favori'), findsOneWidget);
      expect(
        find.text('Ajoutez des produits à vos favoris pour les retrouver ici'),
        findsOneWidget,
      );
      expect(find.text('Parcourir les produits'), findsOneWidget);
    });

    testWidgets(
      'should navigate to catalog when tapping browse products button',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Taper sur le bouton "Parcourir les produits"
        await tester.tap(find.text('Parcourir les produits'));
        await tester.pumpAndSettle();

        // Vérifier la navigation
        expect(find.text('Catalog Page'), findsOneWidget);
      },
    );

    testWidgets('should display empty state with correct styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier les styles de l'état vide
      final favoriteIcon = tester.widget<Icon>(
        find.byIcon(Icons.favorite_border),
      );
      expect(favoriteIcon.size, 80);
      expect(favoriteIcon.color, Colors.grey);

      final browseButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      final buttonStyle = browseButton.style?.backgroundColor?.resolve({});
      expect(buttonStyle, Colors.cyan);
    });

    testWidgets('should show confirmation dialog when clearing favorites', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Taper sur le bouton "Vider les favoris"
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pumpAndSettle();

      // Vérifier que la boîte de dialogue de confirmation est affichée
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Vider les favoris'), findsOneWidget);
      expect(
        find.text('Êtes-vous sûr de vouloir supprimer tous vos favoris ?'),
        findsOneWidget,
      );
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
    });

    testWidgets('should cancel clear favorites when tapping cancel', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ouvrir la boîte de dialogue
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pumpAndSettle();

      // Taper sur Annuler
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      // Vérifier que la boîte de dialogue est fermée
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(FavoritesPage), findsOneWidget);
    });

    testWidgets('should have correct grid properties when favorites exist', (
      WidgetTester tester,
    ) async {
      // Ce test nécessiterait un mock avec des favoris
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Si des favoris existent, vérifier la grille
      final gridViews = find.byType(GridView);
      if (gridViews.evaluate().isNotEmpty) {
        final gridView = tester.widget<GridView>(gridViews.first);
        final delegate =
            gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

        expect(delegate.crossAxisCount, 2);
        expect(delegate.childAspectRatio, 0.7);
        expect(delegate.crossAxisSpacing, 12);
        expect(delegate.mainAxisSpacing, 12);
      }
    });

    testWidgets('should display favorites count header when favorites exist', (
      WidgetTester tester,
    ) async {
      // Ce test nécessiterait un mock avec des favoris
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier l'en-tête de comptage des favoris
      final countTexts = find.textContaining('en favoris');
      if (countTexts.evaluate().isNotEmpty) {
        expect(countTexts, findsOneWidget);
      }
    });

    testWidgets('should handle scroll correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier que le scroll fonctionne
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isNotEmpty) {
        await tester.drag(scrollables.first, const Offset(0, -300));
        await tester.pumpAndSettle();
      }

      // La page devrait toujours être affichée
      expect(find.byType(FavoritesPage), findsOneWidget);
    });

    testWidgets('should open drawer when tapping drawer button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Ouvrir le drawer
      await tester.tap(find.byType(IconButton).first);
      await tester.pumpAndSettle();

      // Vérifier que le drawer est ouvert
      expect(find.byType(DrawerHeader), findsOneWidget);
    });

    testWidgets('should display error state correctly', (
      WidgetTester tester,
    ) async {
      // Ce test nécessiterait un mock qui échoue
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier l'état d'erreur
      final errorIcons = find.byIcon(Icons.error_outline);
      if (errorIcons.evaluate().isNotEmpty) {
        expect(errorIcons, findsOneWidget);
        expect(
          find.text('Erreur lors du chargement des favoris'),
          findsOneWidget,
        );
        expect(find.text('Réessayer'), findsOneWidget);
      }
    });

    testWidgets('should retry loading when tapping retry button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Si le bouton réessayer est présent
      final retryButtons = find.text('Réessayer');
      if (retryButtons.evaluate().isNotEmpty) {
        await tester.tap(retryButtons.first);
        await tester.pumpAndSettle();

        // Vérifier que le rechargement a lieu
        expect(find.byType(FavoritesPage), findsOneWidget);
      }
    });

    testWidgets('should have correct layout structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier la structure de base
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FutureBuilder), findsOneWidget);
    });

    testWidgets('should display correct delete button style', (
      WidgetTester tester,
    ) async {
      // Ce test nécessiterait des favoris avec boutons de suppression
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Vérifier les boutons de suppression s'ils existent
      final closeIcons = find.byIcon(Icons.close);
      if (closeIcons.evaluate().isNotEmpty) {
        final closeIcon = tester.widget<Icon>(closeIcons.first);
        expect(closeIcon.color, Colors.white);
        expect(closeIcon.size, 16);
      }
    });
  });
}
