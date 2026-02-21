import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'hive_service.dart';
import 'models/product_model.dart';
import 'models/recipe_model.dart';
import 'models/settings_model.dart';
import 'models/product_cache_model.dart';
import 'models/nutrition_data_model.dart';
import 'models/health_profile_model.dart';
import 'models/sync_queue_item.dart';

/// Hive service singleton
/// Note: HiveService est statique, ce provider est juste pour injection de dépendances
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

/// Box providers pour accès direct aux boxes Hive
/// Ces providers permettent un accès type-safe aux boxes

final inventoryBoxProvider = Provider<Box<ProductModel>>((ref) {
  return Hive.box<ProductModel>(HiveService.inventoryBoxName);
});

final recipesBoxProvider = Provider<Box<RecipeModel>>((ref) {
  return Hive.box<RecipeModel>(HiveService.recipesBoxName);
});

final settingsBoxProvider = Provider<Box<SettingsModel>>((ref) {
  return Hive.box<SettingsModel>(HiveService.settingsBoxName);
});

final productsCacheBoxProvider = Provider<Box<ProductCacheModel>>((ref) {
  return Hive.box<ProductCacheModel>(HiveService.productsCacheBoxName);
});

final nutritionDataBoxProvider = Provider<Box<NutritionDataModel>>((ref) {
  return Hive.box<NutritionDataModel>(HiveService.nutritionDataBoxName);
});

final healthProfilesBoxProvider = Provider<Box<HealthProfileModel>>((ref) {
  return Hive.box<HealthProfileModel>(HiveService.healthProfilesBoxName);
});

final syncQueueBoxProvider = Provider<Box<SyncQueueItem>>((ref) {
  return Hive.box<SyncQueueItem>(HiveService.syncQueueBoxName);
});
