import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/sync_collections.dart';

void main() {
  group('SyncCollections Tests', () {
    group('Collection Constants', () {
      test('inventoryItems should be correctly defined', () {
        expect(SyncCollections.inventoryItems, 'inventory_items');
      });

      test('nutritionTracking should be correctly defined', () {
        expect(SyncCollections.nutritionTracking, 'nutrition_tracking');
      });

      test('mealPlans should be correctly defined', () {
        expect(SyncCollections.mealPlans, 'meal_plans');
      });

      test('healthProfiles should be correctly defined', () {
        expect(SyncCollections.healthProfiles, 'health_profiles');
      });

      test('nutritionData should be correctly defined', () {
        expect(SyncCollections.nutritionData, 'nutrition_data');
      });

      test('recipes should be correctly defined', () {
        expect(SyncCollections.recipes, 'recipes');
      });

      test('productsCatalog should be correctly defined', () {
        expect(SyncCollections.productsCatalog, 'products_catalog');
      });

      test('all collection names should use snake_case', () {
        final collections = [
          SyncCollections.inventoryItems,
          SyncCollections.nutritionTracking,
          SyncCollections.mealPlans,
          SyncCollections.healthProfiles,
          SyncCollections.nutritionData,
          SyncCollections.recipes,
          SyncCollections.productsCatalog,
        ];

        for (final collection in collections) {
          expect(collection.contains('-'), isFalse);
          expect(collection.contains(' '), isFalse);
          expect(collection, equals(collection.toLowerCase()));
        }
      });

      test('collection names should be unique', () {
        final collections = [
          SyncCollections.inventoryItems,
          SyncCollections.nutritionTracking,
          SyncCollections.mealPlans,
          SyncCollections.healthProfiles,
          SyncCollections.nutritionData,
          SyncCollections.recipes,
          SyncCollections.productsCatalog,
        ];

        final uniqueCollections = collections.toSet();
        expect(uniqueCollections.length, equals(collections.length));
      });
    });

    group('userCollection', () {
      test('should build correct path for inventory_items', () {
        final path = SyncCollections.userCollection(
          'user123',
          SyncCollections.inventoryItems,
        );

        expect(path, 'users/user123/inventory_items');
      });

      test('should build correct path for nutrition_tracking', () {
        final path = SyncCollections.userCollection(
          'user456',
          SyncCollections.nutritionTracking,
        );

        expect(path, 'users/user456/nutrition_tracking');
      });

      test('should build correct path for meal_plans', () {
        final path = SyncCollections.userCollection(
          'user789',
          SyncCollections.mealPlans,
        );

        expect(path, 'users/user789/meal_plans');
      });

      test('should handle different userId formats', () {
        final uuidPath = SyncCollections.userCollection(
          '550e8400-e29b-41d4-a716-446655440000',
          SyncCollections.inventoryItems,
        );

        expect(
          uuidPath,
          'users/550e8400-e29b-41d4-a716-446655440000/inventory_items',
        );
      });

      test('should handle numeric userIds', () {
        final path = SyncCollections.userCollection(
          '12345',
          SyncCollections.healthProfiles,
        );

        expect(path, 'users/12345/health_profiles');
      });

      test('should handle short userIds', () {
        final path = SyncCollections.userCollection(
          'a',
          SyncCollections.nutritionData,
        );

        expect(path, 'users/a/nutrition_data');
      });

      test('should handle very long userIds', () {
        final longUserId = 'u' * 100;
        final path = SyncCollections.userCollection(
          longUserId,
          SyncCollections.inventoryItems,
        );

        expect(path, 'users/$longUserId/inventory_items');
      });

      test('should always start with users/', () {
        final paths = [
          SyncCollections.userCollection('user1', SyncCollections.inventoryItems),
          SyncCollections.userCollection('user2', SyncCollections.nutritionTracking),
          SyncCollections.userCollection('user3', SyncCollections.mealPlans),
        ];

        for (final path in paths) {
          expect(path.startsWith('users/'), isTrue);
        }
      });

      test('should format path correctly with forward slashes', () {
        final path = SyncCollections.userCollection(
          'user123',
          SyncCollections.inventoryItems,
        );

        final parts = path.split('/');
        expect(parts.length, 3);
        expect(parts[0], 'users');
        expect(parts[1], 'user123');
        expect(parts[2], 'inventory_items');
      });

      test('should handle all collection types', () {
        const userId = 'testUser';

        expect(
          SyncCollections.userCollection(userId, SyncCollections.inventoryItems),
          'users/$userId/inventory_items',
        );

        expect(
          SyncCollections.userCollection(userId, SyncCollections.nutritionTracking),
          'users/$userId/nutrition_tracking',
        );

        expect(
          SyncCollections.userCollection(userId, SyncCollections.mealPlans),
          'users/$userId/meal_plans',
        );

        expect(
          SyncCollections.userCollection(userId, SyncCollections.healthProfiles),
          'users/$userId/health_profiles',
        );

        expect(
          SyncCollections.userCollection(userId, SyncCollections.nutritionData),
          'users/$userId/nutrition_data',
        );
      });

      test('should handle custom collection names', () {
        final path = SyncCollections.userCollection(
          'user123',
          'custom_collection',
        );

        expect(path, 'users/user123/custom_collection');
      });

      test('should not modify userId or collection', () {
        const userId = 'USER_123';
        const collection = 'COLLECTION_NAME';

        final path = SyncCollections.userCollection(userId, collection);

        expect(path, 'users/USER_123/COLLECTION_NAME');
      });
    });

    group('User-scoped vs Global collections', () {
      test('user-scoped collections should be for specific users', () {
        final userScopedCollections = [
          SyncCollections.inventoryItems,
          SyncCollections.nutritionTracking,
          SyncCollections.mealPlans,
          SyncCollections.healthProfiles,
          SyncCollections.nutritionData,
        ];

        // These should be used with userCollection()
        for (final collection in userScopedCollections) {
          final path = SyncCollections.userCollection('user123', collection);
          expect(path.contains('user123'), isTrue);
        }
      });

      test('global collections should be read-only catalogs', () {
        final globalCollections = [
          SyncCollections.recipes,
          SyncCollections.productsCatalog,
        ];

        // These are used directly without userCollection()
        for (final collection in globalCollections) {
          expect(collection.contains('/'), isFalse);
        }
      });
    });

    group('Edge cases', () {
      test('should handle empty userId', () {
        final path = SyncCollections.userCollection(
          '',
          SyncCollections.inventoryItems,
        );

        expect(path, 'users//inventory_items');
      });

      test('should handle empty collection', () {
        final path = SyncCollections.userCollection('user123', '');

        expect(path, 'users/user123/');
      });

      test('should handle userId with special characters', () {
        final path = SyncCollections.userCollection(
          'user@test.com',
          SyncCollections.inventoryItems,
        );

        expect(path, 'users/user@test.com/inventory_items');
      });

      test('should handle collection with underscores', () {
        final path = SyncCollections.userCollection(
          'user123',
          'my_custom_collection',
        );

        expect(path, 'users/user123/my_custom_collection');
      });

      test('should not have trailing slash', () {
        final path = SyncCollections.userCollection(
          'user123',
          SyncCollections.inventoryItems,
        );

        expect(path.endsWith('/'), isFalse);
      });
    });
  });
}
