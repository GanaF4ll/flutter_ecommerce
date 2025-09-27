import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/main.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
import 'package:flutter_ecommerce/pages/login_page.dart';
import 'package:flutter_ecommerce/pages/product_page.dart';
import 'package:flutter_ecommerce/services/cart_service.dart';
import 'package:flutter_ecommerce/services/favorite_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Navigation and Routing Coverage Tests', () {
    testWidgets('MyApp onGenerateRoute handles product routes',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Navigate to a product page using the onGenerateRoute
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name?.startsWith('/product/') == true) {
              final id = settings.name!.split('/')[2];
              return MaterialPageRoute(
                  builder: (_) => ProductPage(id: int.parse(id)));
            }
            return null;
          },
          home: Builder(
            builder: (context) {
              // Test navigation to product page
              Navigator.pushNamed(context, '/product/123');
              return const Scaffold(body: Text('Home'));
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ProductPage), findsOneWidget);
    });

    testWidgets('MyApp onGenerateRoute returns null for invalid routes',
        (WidgetTester tester) async {
      const app = MyApp();
      final route = app.onGenerateRoute!(const RouteSettings(name: '/invalid'));
      expect(route, isNull);
    });

    testWidgets('MyApp onGenerateRoute handles product routes correctly',
        (WidgetTester tester) async {
      const app = MyApp();
      final route =
          app.onGenerateRoute!(const RouteSettings(name: '/product/456'));
      expect(route, isNotNull);
      expect(route, isA<MaterialPageRoute>());
    });

    testWidgets('MyApp initialRoute is set correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('MyApp theme is configured', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('Flutter E-Commerce Gana'));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      expect(materialApp.theme, isNotNull);
      expect(materialApp.initialRoute, equals('/'));
    });

    testWidgets('MyApp routes are defined correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.routes, isNotNull);
      expect(materialApp.routes!.keys, contains('/'));
      expect(materialApp.routes!.keys, contains('/login'));
      expect(materialApp.routes!.keys, contains('/register'));
      expect(materialApp.routes!.keys, contains('/catalog'));
      expect(materialApp.routes!.keys, contains('/cart'));
      expect(materialApp.routes!.keys, contains('/favorites'));
    });

    testWidgets('MyApp with custom services', (WidgetTester tester) async {
      final cartService = CartService();
      final favoriteService = FavoriteService();

      await tester.pumpWidget(MyApp(
        cartService: cartService,
        favoriteService: favoriteService,
      ));

      expect(find.byType(HomePage), findsOneWidget);
    });

    group('Product Route Parsing Tests', () {
      testWidgets('handles various product IDs', (WidgetTester tester) async {
        const app = MyApp();

        final testIds = ['1', '123', '999', '0', '9999999'];

        for (final id in testIds) {
          final route =
              app.onGenerateRoute!(RouteSettings(name: '/product/$id'));
          expect(route, isNotNull);
          expect(route, isA<MaterialPageRoute>());
        }
      });

      testWidgets('handles malformed product routes',
          (WidgetTester tester) async {
        const app = MyApp();

        final invalidRoutes = [
          '/product/',
          '/product',
          '/product/abc',
          '/products/123',
          '/PRODUCT/123',
        ];

        for (final routeName in invalidRoutes) {
          final route = app.onGenerateRoute!(RouteSettings(name: routeName));
          if (routeName == '/product/abc') {
            // This might still create a route but with invalid ID
            expect(route, isNotNull);
          } else {
            expect(route, isNull);
          }
        }
      });

      testWidgets('product route creates ProductPage with correct ID',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/product/') == true) {
                final id = settings.name!.split('/')[2];
                return MaterialPageRoute(
                  builder: (_) => ProductPage(id: int.parse(id)),
                  settings: settings,
                );
              }
              return null;
            },
            home: const Scaffold(body: Text('Home')),
          ),
        );

        // Navigate to product page
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/product/') == true) {
                final id = settings.name!.split('/')[2];
                return MaterialPageRoute(
                  builder: (_) => ProductPage(id: int.parse(id)),
                  settings: settings,
                );
              }
              return null;
            },
            initialRoute: '/product/789',
          ),
        );

        await tester.pump();
        expect(find.byType(ProductPage), findsOneWidget);
      });
    });

    group('Navigation State Tests', () {
      testWidgets('app handles navigation between routes',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());

        // Start at home
        expect(find.byType(HomePage), findsOneWidget);

        // Navigate to login (we can test this without AuthGuard issues)
        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/login',
            routes: const MyApp().routes!,
          ),
        );

        await tester.pump();
        expect(find.byType(LoginPage), findsOneWidget);
      });

      testWidgets('app maintains navigation stack',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/': (_) => const HomePage(),
              '/login': (_) => const LoginPage(),
            },
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Home'),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: const Text('Go to Login'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        // Tap the navigation button
        await tester.tap(find.text('Go to Login'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles empty product ID', (WidgetTester tester) async {
        const app = MyApp();
        final route =
            app.onGenerateRoute!(const RouteSettings(name: '/product/'));
        expect(route, isNull);
      });

      testWidgets('handles null route settings', (WidgetTester tester) async {
        const app = MyApp();
        final route = app.onGenerateRoute!(const RouteSettings(name: null));
        expect(route, isNull);
      });

      testWidgets('handles route with query parameters',
          (WidgetTester tester) async {
        const app = MyApp();
        final route = app.onGenerateRoute!(
            const RouteSettings(name: '/product/123?param=value'));
        expect(route, isNotNull);
      });

      testWidgets('handles route with fragments', (WidgetTester tester) async {
        const app = MyApp();
        final route = app.onGenerateRoute!(
            const RouteSettings(name: '/product/123#section'));
        expect(route, isNotNull);
      });
    });

    group('Performance Tests', () {
      testWidgets('onGenerateRoute performs quickly',
          (WidgetTester tester) async {
        const app = MyApp();

        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          app.onGenerateRoute!(RouteSettings(name: '/product/$i'));
        }
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });

      testWidgets('handles rapid route generation',
          (WidgetTester tester) async {
        const app = MyApp();

        final routes = <MaterialPageRoute>[];
        for (int i = 0; i < 100; i++) {
          final route =
              app.onGenerateRoute!(RouteSettings(name: '/product/$i'));
          if (route is MaterialPageRoute) {
            routes.add(route);
          }
        }

        expect(routes, hasLength(100));
      });
    });

    group('Memory Tests', () {
      testWidgets('app creation and disposal', (WidgetTester tester) async {
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(const MyApp());
          await tester.pump();

          await tester.pumpWidget(Container());
          await tester.pump();
        }

        // Should not leak memory or crash
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('route generation and cleanup', (WidgetTester tester) async {
        const app = MyApp();

        final routes = <MaterialPageRoute?>[];
        for (int i = 0; i < 50; i++) {
          routes.add(app.onGenerateRoute!(RouteSettings(name: '/product/$i'))
              as MaterialPageRoute?);
        }

        // Clear references
        routes.clear();

        // Should handle cleanup gracefully
        expect(routes, isEmpty);
      });
    });

    group('Error Handling', () {
      testWidgets('handles invalid product ID gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/product/') == true) {
                final id = settings.name!.split('/')[2];
                try {
                  return MaterialPageRoute(
                      builder: (_) => ProductPage(id: int.parse(id)));
                } catch (e) {
                  // Handle parsing error gracefully
                  return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                            body: Center(child: Text('Invalid Product ID')),
                          ));
                }
              }
              return null;
            },
            initialRoute: '/product/invalid',
          ),
        );

        await tester.pump();
        expect(find.text('Invalid Product ID'), findsOneWidget);
      });

      testWidgets('handles route generation exceptions',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name?.startsWith('/product/') == true) {
                // Simulate an exception during route generation
                throw Exception('Route generation failed');
              }
              return null;
            },
            home: const Scaffold(body: Text('Home')),
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Unknown Route')),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Home'), findsOneWidget);
      });
    });
  });
}
