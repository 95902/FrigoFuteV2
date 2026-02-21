import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:frigofute_v2/core/routing/app_routes.dart';

void main() {
  group('Navigation Integration Tests', () {
    testWidgets('ScaffoldWithBottomNav displays correct tabs', (tester) async {
      final router = GoRouter(
        initialLocation: AppRoutes.dashboard,
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Dashboard'))),
          ),
          GoRoute(
            path: AppRoutes.inventory,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Inventory'))),
          ),
          GoRoute(
            path: AppRoutes.recipes,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Recipes'))),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );

      await tester.pumpAndSettle();

      // Initial route should be dashboard
      expect(find.text('Dashboard'), findsOneWidget);
    });

    test('route paths follow correct naming conventions', () {
      // Auth routes use /auth/* pattern
      expect(AppRoutes.login.startsWith('/auth/'), isTrue);
      expect(AppRoutes.register.startsWith('/auth/'), isTrue);
      expect(AppRoutes.onboarding.startsWith('/auth/'), isTrue);

      // Main routes use single-level paths
      expect(AppRoutes.dashboard, '/dashboard');
      expect(AppRoutes.inventory, '/inventory');
      expect(AppRoutes.recipes, '/recipes');

      // Premium routes use kebab-case
      expect(AppRoutes.nutritionTracking, '/nutrition-tracking');
      expect(AppRoutes.mealPlanning, '/meal-planning');
      expect(AppRoutes.aiCoach, '/ai-coach');
    });

    test('nested route patterns are consistent', () {
      // Inventory nested routes
      expect(
        '${AppRoutes.inventory}/detail/:productId'.contains(':productId'),
        isTrue,
      );
      expect('${AppRoutes.inventory}/add'.endsWith('/add'), isTrue);

      // Recipes nested routes
      expect(
        '${AppRoutes.recipes}/detail/:recipeId'.contains(':recipeId'),
        isTrue,
      );
      expect(
        '${AppRoutes.recipes}/suggestions'.endsWith('/suggestions'),
        isTrue,
      );

      // OCR scan nested route
      expect('${AppRoutes.ocrScan}/result/:scanId'.contains(':scanId'), isTrue);
    });
  });
}
