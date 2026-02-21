import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/routing/app_routes.dart';

void main() {
  group('AppRoutes Extended Tests', () {
    group('Route Path Validation', () {
      test('all routes should start with forward slash', () {
        final routes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.onboarding,
          AppRoutes.dashboard,
          AppRoutes.inventory,
          AppRoutes.recipes,
          AppRoutes.ocrScan,
          AppRoutes.notifications,
          AppRoutes.nutritionTracking,
          AppRoutes.nutritionProfiles,
          AppRoutes.mealPlanning,
          AppRoutes.aiCoach,
          AppRoutes.gamification,
          AppRoutes.shoppingList,
          AppRoutes.familySharing,
          AppRoutes.priceComparator,
          AppRoutes.paywall,
          AppRoutes.notFound,
        ];

        for (final route in routes) {
          expect(route.startsWith('/'), isTrue, reason: 'Route $route should start with /');
        }
      });

      test('routes should not end with trailing slash', () {
        final routes = [
          AppRoutes.login,
          AppRoutes.dashboard,
          AppRoutes.inventory,
          AppRoutes.paywall,
        ];

        for (final route in routes) {
          expect(route.endsWith('/'), isFalse, reason: 'Route $route should not end with /');
        }
      });

      test('routes should use kebab-case for multi-word names', () {
        expect(AppRoutes.nutritionTracking.contains('_'), isFalse);
        expect(AppRoutes.mealPlanning.contains('_'), isFalse);
        expect(AppRoutes.aiCoach.contains('_'), isFalse);

        expect(AppRoutes.nutritionTracking.contains('-'), isTrue);
        expect(AppRoutes.mealPlanning.contains('-'), isTrue);
        expect(AppRoutes.aiCoach.contains('-'), isTrue);
      });

      test('routes should be lowercase', () {
        final routes = [
          AppRoutes.login,
          AppRoutes.dashboard,
          AppRoutes.nutritionTracking,
          AppRoutes.mealPlanning,
        ];

        for (final route in routes) {
          expect(route, equals(route.toLowerCase()), reason: 'Route $route should be lowercase');
        }
      });
    });

    group('Public Routes', () {
      test('all auth routes should be public', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.login), isTrue);
        expect(AppRoutes.isPublicRoute(AppRoutes.register), isTrue);
        expect(AppRoutes.isPublicRoute(AppRoutes.onboarding), isTrue);
        expect(AppRoutes.isPublicRoute(AppRoutes.forgotPassword), isTrue);
      });

      test('non-auth routes should not be public', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.dashboard), isFalse);
        expect(AppRoutes.isPublicRoute(AppRoutes.inventory), isFalse);
        expect(AppRoutes.isPublicRoute(AppRoutes.recipes), isFalse);
      });

      test('special routes should not be public', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.paywall), isFalse);
        expect(AppRoutes.isPublicRoute(AppRoutes.notFound), isFalse);
      });

      test('should handle case sensitivity in public route check', () {
        expect(AppRoutes.isPublicRoute('/AUTH/LOGIN'), isFalse);
        expect(AppRoutes.isPublicRoute('/auth/LOGIN'), isFalse);
      });

      test('should handle partial matches correctly', () {
        expect(AppRoutes.isPublicRoute('/auth'), isFalse);
        expect(AppRoutes.isPublicRoute('/authentication'), isFalse);
      });
    });

    group('Premium Routes', () {
      test('all premium features should be premium routes', () {
        final premiumRoutes = [
          AppRoutes.nutritionTracking,
          AppRoutes.nutritionProfiles,
          AppRoutes.mealPlanning,
          AppRoutes.aiCoach,
          AppRoutes.gamification,
          AppRoutes.shoppingList,
          AppRoutes.familySharing,
          AppRoutes.priceComparator,
        ];

        for (final route in premiumRoutes) {
          expect(AppRoutes.isPremiumRoute(route), isTrue, reason: 'Route $route should be premium');
        }
      });

      test('free features should not be premium routes', () {
        final freeRoutes = [
          AppRoutes.dashboard,
          AppRoutes.inventory,
          AppRoutes.recipes,
          AppRoutes.ocrScan,
          AppRoutes.notifications,
        ];

        for (final route in freeRoutes) {
          expect(AppRoutes.isPremiumRoute(route), isFalse, reason: 'Route $route should be free');
        }
      });

      test('auth routes should not be premium routes', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.login), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.register), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.onboarding), isFalse);
      });
    });

    group('Query Parameters', () {
      test('should handle routes with single query parameter', () {
        const routeWithQuery = '${AppRoutes.dashboard}?tab=overview';
        expect(AppRoutes.isPublicRoute(routeWithQuery), isFalse);
        expect(AppRoutes.isPremiumRoute(routeWithQuery), isFalse);
      });

      test('should handle routes with multiple query parameters', () {
        const routeWithQuery = '${AppRoutes.recipes}?category=vegetarian&maxTime=30';
        expect(AppRoutes.isPublicRoute(routeWithQuery), isFalse);
        expect(AppRoutes.isPremiumRoute(routeWithQuery), isFalse);
      });

      test('should handle routes with hash fragments', () {
        const routeWithHash = '${AppRoutes.dashboard}#section-1';
        expect(AppRoutes.isPublicRoute(routeWithHash), isFalse);
      });

      test('should handle empty query parameters', () {
        const routeWithEmptyQuery = '${AppRoutes.dashboard}?';
        expect(AppRoutes.isPublicRoute(routeWithEmptyQuery), isFalse);
      });
    });

    group('Route Groups', () {
      test('should correctly categorize all routes', () {
        final allRoutes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.onboarding,
          AppRoutes.dashboard,
          AppRoutes.inventory,
          AppRoutes.recipes,
          AppRoutes.nutritionTracking,
          AppRoutes.mealPlanning,
        ];

        for (final route in allRoutes) {
          final isPublic = AppRoutes.isPublicRoute(route);
          final isPremium = AppRoutes.isPremiumRoute(route);

          // A route cannot be both public and premium
          expect(isPublic && isPremium, isFalse, reason: 'Route $route cannot be both public and premium');
        }
      });

      test('should have at least one public route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.login), isTrue);
      });

      test('should have at least one premium route', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.nutritionTracking), isTrue);
      });

      test('should have at least one free protected route', () {
        const route = AppRoutes.dashboard;
        expect(AppRoutes.isPublicRoute(route), isFalse);
        expect(AppRoutes.isPremiumRoute(route), isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle empty string route', () {
        expect(AppRoutes.isPublicRoute(''), isFalse);
        expect(AppRoutes.isPremiumRoute(''), isFalse);
      });

      test('should handle root route', () {
        expect(AppRoutes.isPublicRoute('/'), isFalse);
        expect(AppRoutes.isPremiumRoute('/'), isFalse);
      });

      test('should handle non-existent routes', () {
        expect(AppRoutes.isPublicRoute('/non-existent'), isFalse);
        expect(AppRoutes.isPremiumRoute('/non-existent'), isFalse);
      });

      test('should handle routes with trailing slashes', () {
        expect(AppRoutes.isPublicRoute('${AppRoutes.login}/'), isTrue);
        expect(AppRoutes.isPremiumRoute('${AppRoutes.nutritionTracking}/'), isTrue);
      });

      test('should handle deeply nested paths', () {
        const deepRoute = '${AppRoutes.inventory}/detail/123/edit/notes';
        expect(AppRoutes.isPublicRoute(deepRoute), isFalse);
        expect(AppRoutes.isPremiumRoute(deepRoute), isFalse);
      });

      test('should handle routes with special characters', () {
        const routeWithSpecial = '${AppRoutes.dashboard}?param=value&other=test%20value';
        expect(AppRoutes.isPublicRoute(routeWithSpecial), isFalse);
      });
    });

    group('Route Constants Immutability', () {
      test('route constants should not change', () {
        // These values should remain constant
        expect(AppRoutes.login, '/auth/login');
        expect(AppRoutes.dashboard, '/dashboard');
        expect(AppRoutes.inventory, '/inventory');
      });

      test('route constants should be unique', () {
        final routes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.dashboard,
          AppRoutes.inventory,
          AppRoutes.recipes,
          AppRoutes.nutritionTracking,
          AppRoutes.mealPlanning,
          AppRoutes.aiCoach,
        ];

        final uniqueRoutes = routes.toSet();
        expect(uniqueRoutes.length, equals(routes.length), reason: 'All routes should be unique');
      });
    });
  });
}
