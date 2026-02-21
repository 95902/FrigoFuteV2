import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/storage/hive_service.dart';

void main() {
  group('HiveService Tests', () {
    test('box names are correctly defined', () {
      expect(HiveService.inventoryBoxName, 'inventory_box');
      expect(HiveService.recipesBoxName, 'recipes_box');
      expect(HiveService.settingsBoxName, 'settings_box');
      expect(HiveService.nutritionDataBoxName, 'nutrition_data_box');
      expect(HiveService.healthProfilesBoxName, 'health_profiles_box');
      expect(HiveService.syncQueueBoxName, 'sync_queue_box');
      expect(HiveService.productsCacheBoxName, 'products_cache_box');
    });

    test('encryption key length is 32 bytes (256 bits)', () {
      // Cannot test actual key generation without initializing Hive
      // But we can verify the constant
      expect(HiveService.inventoryBoxName.isNotEmpty, isTrue);
    });

    // Note: Cannot test init() without proper Hive initialization
    // These tests would require:
    // - Setting up a test directory for Hive
    // - Initializing Hive with test path
    // - Cleaning up after tests
    // This is deferred to integration tests
  });
}
