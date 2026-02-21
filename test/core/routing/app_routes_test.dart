import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/routing/app_routes.dart';

void main() {
  group('AppRoutes Tests', () {
    group('Route Constants', () {
      test('has correct login route', () {
        expect(AppRoutes.login, '/auth/login');
      });

      test('has correct register route', () {
        expect(AppRoutes.register, '/auth/register');
      });

      test('has correct dashboard route', () {
        expect(AppRoutes.dashboard, '/dashboard');
      });

      test('has correct inventory route', () {
        expect(AppRoutes.inventory, '/inventory');
      });

      test('has correct nutrition tracking route', () {
        expect(AppRoutes.nutritionTracking, '/nutrition-tracking');
      });

      test('has correct paywall route', () {
        expect(AppRoutes.paywall, '/paywall');
      });
    });

    group('isPublicRoute', () {
      test('returns true for login route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.login), isTrue);
      });

      test('returns true for register route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.register), isTrue);
      });

      test('returns true for onboarding route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.onboarding), isTrue);
      });

      test('returns false for dashboard route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.dashboard), isFalse);
      });

      test('returns false for inventory route', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.inventory), isFalse);
      });

      test('returns false for premium routes', () {
        expect(AppRoutes.isPublicRoute(AppRoutes.nutritionTracking), isFalse);
        expect(AppRoutes.isPublicRoute(AppRoutes.mealPlanning), isFalse);
        expect(AppRoutes.isPublicRoute(AppRoutes.aiCoach), isFalse);
      });

      test('handles routes with query parameters', () {
        expect(AppRoutes.isPublicRoute('/auth/login?redirect=/dashboard'), isTrue);
        expect(AppRoutes.isPublicRoute('/dashboard?tab=overview'), isFalse);
      });
    });

    group('isPremiumRoute', () {
      test('returns false for free routes', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.dashboard), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.inventory), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.recipes), isFalse);
      });

      test('returns false for auth routes', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.login), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.register), isFalse);
      });

      test('returns true for nutrition tracking', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.nutritionTracking), isTrue);
      });

      test('returns true for meal planning', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.mealPlanning), isTrue);
      });

      test('returns true for AI coach', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.aiCoach), isTrue);
      });

      test('returns true for gamification', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.gamification), isTrue);
      });

      test('returns true for family sharing', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.familySharing), isTrue);
      });

      test('returns true for shopping list', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.shoppingList), isTrue);
      });

      test('returns true for nutrition profiles', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.nutritionProfiles), isTrue);
      });

      test('returns true for price comparator', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.priceComparator), isTrue);
      });

      test('handles routes with query parameters', () {
        expect(AppRoutes.isPremiumRoute('/nutrition-tracking?date=2024-01-01'), isTrue);
        expect(AppRoutes.isPremiumRoute('/dashboard?premium=false'), isFalse);
      });

      test('returns false for special routes', () {
        expect(AppRoutes.isPremiumRoute(AppRoutes.paywall), isFalse);
        expect(AppRoutes.isPremiumRoute(AppRoutes.notFound), isFalse);
      });
    });

    group('Route Categorization Logic', () {
      test('no route should be both public and premium', () {
        final allRoutes = [
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.onboarding,
          AppRoutes.inventory,
          AppRoutes.dashboard,
          AppRoutes.recipes,
          AppRoutes.nutritionTracking,
          AppRoutes.mealPlanning,
          AppRoutes.aiCoach,
          AppRoutes.gamification,
          AppRoutes.familySharing,
          AppRoutes.shoppingList,
          AppRoutes.priceComparator,
          AppRoutes.nutritionProfiles,
        ];

        for (final route in allRoutes) {
          final isPublic = AppRoutes.isPublicRoute(route);
          final isPremium = AppRoutes.isPremiumRoute(route);

          expect(
            isPublic && isPremium,
            isFalse,
            reason: 'Route $route should not be both public and premium',
          );
        }
      });
    });
  });
}
