/// Firestore collections for sync
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Defines the Firestore collection names used by the sync system.
/// Provides path helpers for user-scoped and global collections.
class SyncCollections {
  // User-scoped collections (require userId)
  /// Inventory items collection (Epic 2)
  static const String inventoryItems = 'inventory_items';

  /// Nutrition tracking data collection (Epic 7)
  static const String nutritionTracking = 'nutrition_tracking';

  /// Meal plans collection (Epic 9)
  static const String mealPlans = 'meal_plans';

  /// User health profiles collection (Epic 8)
  static const String healthProfiles = 'health_profiles';

  /// Detailed nutrition data collection (Epic 7)
  static const String nutritionData = 'nutrition_data';

  // Global read-only collections (synced down to Hive)
  /// Recipes database (Epic 6)
  static const String recipes = 'recipes';

  /// Products catalog from OpenFoodFacts (Epic 5)
  static const String productsCatalog = 'products_catalog';

  /// Build Firestore path for user-scoped collection
  ///
  /// Example:
  /// ```dart
  /// final path = SyncCollections.userCollection('user123', 'inventory_items');
  /// // Returns: 'users/user123/inventory_items'
  /// ```
  static String userCollection(String userId, String collection) =>
      'users/$userId/$collection';
}
