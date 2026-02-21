import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/core/monitoring/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

class MockFirebaseAnalyticsObserver extends Mock
    implements FirebaseAnalyticsObserver {}

void main() {
  group('AnalyticsService', () {
    late AnalyticsService service;

    setUp(() {
      service = AnalyticsService();
    });

    group('getNavigatorObserver', () {
      test('returns FirebaseAnalyticsObserver', () {
        // Act
        final observer = service.getNavigatorObserver();

        // Assert
        expect(observer, isNotNull);
        expect(observer, isA<FirebaseAnalyticsObserver>());
      });
    });

    group('logEvent', () {
      test('logs event with name only', () async {
        // Act & Assert - should not throw
        await service.logEvent(name: 'test_event');
      });

      test('logs event with parameters', () async {
        // Act & Assert - should not throw
        await service.logEvent(
          name: 'test_event',
          parameters: {
            'param1': 'value1',
            'param2': 42,
            'param3': true,
          },
        );
      });

      test('logs event with null parameters', () async {
        // Act & Assert - should not throw
        await service.logEvent(
          name: 'test_event',
          parameters: null,
        );
      });
    });

    group('logScreenView', () {
      test('logs screen view with screen name', () async {
        // Act & Assert - should not throw
        await service.logScreenView(screenName: 'HomeScreen');
      });

      test('logs screen view with screen name and class', () async {
        // Act & Assert - should not throw
        await service.logScreenView(
          screenName: 'HomeScreen',
          screenClass: 'HomeScreenWidget',
        );
      });
    });

    group('setUserProperty', () {
      test('sets user property with value', () async {
        // Act & Assert - should not throw
        await service.setUserProperty(
          name: 'user_tier',
          value: 'premium',
        );
      });

      test('sets user property with null value', () async {
        // Act & Assert - should not throw
        await service.setUserProperty(
          name: 'user_tier',
          value: null,
        );
      });
    });

    group('setUserId', () {
      test('sets user ID', () async {
        // Act & Assert - should not throw
        await service.setUserId('hashed_user_123');
      });

      test('sets null user ID', () async {
        // Act & Assert - should not throw
        await service.setUserId(null);
      });
    });

    group('clearUserId', () {
      test('clears user ID', () async {
        // Act & Assert - should not throw
        await service.clearUserId();
      });
    });

    group('setAnalyticsCollectionEnabled', () {
      test('enables analytics collection', () async {
        // Act & Assert - should not throw
        await service.setAnalyticsCollectionEnabled(true);
      });

      test('disables analytics collection', () async {
        // Act & Assert - should not throw
        await service.setAnalyticsCollectionEnabled(false);
      });
    });

    group('Business Events', () {
      group('logProductAdded', () {
        test('logs product added with all parameters', () async {
          // Act & Assert - should not throw
          await service.logProductAdded(
            method: 'barcode',
            category: 'dairy',
            storageLocation: 'fridge',
          );
        });

        test('logs product added without storage location', () async {
          // Act & Assert - should not throw
          await service.logProductAdded(
            method: 'manual',
            category: 'vegetables',
          );
        });

        test('logs product added with different methods', () async {
          // Act & Assert - should not throw
          await service.logProductAdded(
            method: 'manual',
            category: 'fruits',
          );

          await service.logProductAdded(
            method: 'barcode',
            category: 'meat',
          );

          await service.logProductAdded(
            method: 'ocr',
            category: 'dairy',
          );
        });
      });

      group('logOCRScan', () {
        test('logs OCR scan with all parameters', () async {
          // Act & Assert - should not throw
          await service.logOCRScan(
            engine: 'google_vision',
            success: true,
            confidence: 95,
            itemsDetected: 12,
          );
        });

        test('logs failed OCR scan', () async {
          // Act & Assert - should not throw
          await service.logOCRScan(
            engine: 'ml_kit',
            success: false,
          );
        });

        test('logs OCR scan without optional parameters', () async {
          // Act & Assert - should not throw
          await service.logOCRScan(
            engine: 'google_vision',
            success: true,
          );
        });
      });

      group('logRecipeViewed', () {
        test('logs recipe viewed with all parameters', () async {
          // Act & Assert - should not throw
          await service.logRecipeViewed(
            recipeId: 'recipe_123',
            source: 'search',
            dietaryTags: ['vegetarian', 'gluten_free'],
          );
        });

        test('logs recipe viewed without dietary tags', () async {
          // Act & Assert - should not throw
          await service.logRecipeViewed(
            recipeId: 'recipe_456',
            source: 'expiring_soon',
          );
        });

        test('logs recipe viewed with empty dietary tags', () async {
          // Act & Assert - should not throw
          await service.logRecipeViewed(
            recipeId: 'recipe_789',
            source: 'favorites',
            dietaryTags: [],
          );
        });

        test('logs recipe viewed from different sources', () async {
          // Act & Assert - should not throw
          await service.logRecipeViewed(
            recipeId: 'recipe_1',
            source: 'search',
          );

          await service.logRecipeViewed(
            recipeId: 'recipe_2',
            source: 'expiring_soon',
          );

          await service.logRecipeViewed(
            recipeId: 'recipe_3',
            source: 'favorites',
          );
        });
      });

      group('logMealPlanGenerated', () {
        test('logs meal plan generated with all parameters', () async {
          // Act & Assert - should not throw
          await service.logMealPlanGenerated(
            profileType: 'muscle_gain',
            durationDays: 7,
            recipesGenerated: 21,
          );
        });

        test('logs meal plan generated without recipes count', () async {
          // Act & Assert - should not throw
          await service.logMealPlanGenerated(
            profileType: 'weight_loss',
            durationDays: 14,
          );
        });

        test('logs meal plan for different profiles', () async {
          // Act & Assert - should not throw
          await service.logMealPlanGenerated(
            profileType: 'maintenance',
            durationDays: 7,
          );

          await service.logMealPlanGenerated(
            profileType: 'muscle_gain',
            durationDays: 30,
          );
        });
      });

      group('logPremiumFeatureAccessed', () {
        test('logs premium feature accessed with access', () async {
          // Act & Assert - should not throw
          await service.logPremiumFeatureAccessed(
            featureName: 'nutrition_tracking',
            hasAccess: true,
          );
        });

        test('logs premium feature accessed without access', () async {
          // Act & Assert - should not throw
          await service.logPremiumFeatureAccessed(
            featureName: 'ai_meal_planning',
            hasAccess: false,
          );
        });

        test('logs different premium features', () async {
          // Act & Assert - should not throw
          await service.logPremiumFeatureAccessed(
            featureName: 'nutrition_tracking',
            hasAccess: false,
          );

          await service.logPremiumFeatureAccessed(
            featureName: 'price_comparison',
            hasAccess: false,
          );

          await service.logPremiumFeatureAccessed(
            featureName: 'unlimited_recipes',
            hasAccess: true,
          );
        });
      });

      group('logFoodWastePrevented', () {
        test('logs food waste prevented', () async {
          // Act & Assert - should not throw
          await service.logFoodWastePrevented(
            category: 'vegetables',
            estimatedValueEur: 3.50,
            estimatedWeightKg: 0.5,
          );
        });

        test('logs food waste prevented for different categories', () async {
          // Act & Assert - should not throw
          await service.logFoodWastePrevented(
            category: 'dairy',
            estimatedValueEur: 2.0,
            estimatedWeightKg: 0.3,
          );

          await service.logFoodWastePrevented(
            category: 'meat',
            estimatedValueEur: 8.0,
            estimatedWeightKg: 0.4,
          );

          await service.logFoodWastePrevented(
            category: 'fruits',
            estimatedValueEur: 1.5,
            estimatedWeightKg: 0.2,
          );
        });
      });

      group('logSyncCompleted', () {
        test('logs sync completed with all parameters', () async {
          // Act & Assert - should not throw
          await service.logSyncCompleted(
            phase: 'upload',
            success: true,
            itemsSynced: 15,
            durationMs: 1250,
          );
        });

        test('logs failed sync', () async {
          // Act & Assert - should not throw
          await service.logSyncCompleted(
            phase: 'download',
            success: false,
          );
        });

        test('logs sync without optional parameters', () async {
          // Act & Assert - should not throw
          await service.logSyncCompleted(
            phase: 'conflict_resolution',
            success: true,
          );
        });

        test('logs different sync phases', () async {
          // Act & Assert - should not throw
          await service.logSyncCompleted(
            phase: 'upload',
            success: true,
          );

          await service.logSyncCompleted(
            phase: 'download',
            success: true,
          );

          await service.logSyncCompleted(
            phase: 'conflict_resolution',
            success: true,
          );
        });
      });
    });

    group('Predefined Firebase Events', () {
      test('logSignUp', () async {
        // Act & Assert - should not throw
        await service.logSignUp(method: 'google');
      });

      test('logLogin', () async {
        // Act & Assert - should not throw
        await service.logLogin(method: 'email');
      });

      test('logAppOpen', () async {
        // Act & Assert - should not throw
        await service.logAppOpen();
      });

      test('logTutorialBegin', () async {
        // Act & Assert - should not throw
        await service.logTutorialBegin();
      });

      test('logTutorialComplete', () async {
        // Act & Assert - should not throw
        await service.logTutorialComplete();
      });

      test('logSearch', () async {
        // Act & Assert - should not throw
        await service.logSearch(searchTerm: 'pasta recipes');
      });

      test('logShare', () async {
        // Act & Assert - should not throw
        await service.logShare(
          contentType: 'recipe',
          itemId: 'recipe_123',
          method: 'whatsapp',
        );
      });
    });
  });
}
