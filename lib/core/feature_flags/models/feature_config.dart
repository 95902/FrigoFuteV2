import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

part 'feature_config.freezed.dart';
part 'feature_config.g.dart';

/// Feature configuration model
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Defines 14 feature flags:
/// - 6 Free modules (inventory, ocr_scan, notifications, recipes, dashboard, auth_profile)
/// - 8 Premium modules (meal_planning, ai_coach, price_comparator, gamification,
///   export_sharing, family_sharing, shopping_list, nutrition_tracking)
@freezed
abstract class FeatureConfig with _$FeatureConfig {
  const FeatureConfig._();

  const factory FeatureConfig({
    // Free modules (6)
    required bool inventoryEnabled,
    required bool ocrScanEnabled,
    required bool notificationsEnabled,
    required bool recipesEnabled,
    required bool dashboardEnabled,
    required bool authProfileEnabled,

    // Premium modules (8)
    required bool mealPlanningEnabled,
    required bool aiCoachEnabled,
    required bool priceComparatorEnabled,
    required bool gamificationEnabled,
    required bool exportSharingEnabled,
    required bool familySharingEnabled,
    required bool shoppingListEnabled,
    required bool nutritionTrackingEnabled,

    // Premium features list
    required List<String> premiumFeatures,
  }) = _FeatureConfig;

  /// Check if user has premium access
  ///
  /// Returns true if any premium features are available
  bool get isPremium => premiumFeatures.isNotEmpty;

  /// Check if specific feature is enabled
  ///
  /// Example:
  /// ```dart
  /// if (config.isEnabled('meal_planning')) {
  ///   // Meal planning is enabled
  /// }
  /// ```
  bool isEnabled(String featureId) {
    switch (featureId) {
      // Free modules
      case 'inventory':
        return inventoryEnabled;
      case 'ocr_scan':
        return ocrScanEnabled;
      case 'notifications':
        return notificationsEnabled;
      case 'recipes':
        return recipesEnabled;
      case 'dashboard':
        return dashboardEnabled;
      case 'auth_profile':
        return authProfileEnabled;

      // Premium modules
      case 'meal_planning':
        return mealPlanningEnabled;
      case 'ai_coach':
        return aiCoachEnabled;
      case 'price_comparator':
        return priceComparatorEnabled;
      case 'gamification':
        return gamificationEnabled;
      case 'export_sharing':
        return exportSharingEnabled;
      case 'family_sharing':
        return familySharingEnabled;
      case 'shopping_list':
        return shoppingListEnabled;
      case 'nutrition_tracking':
        return nutritionTrackingEnabled;

      default:
        return false;
    }
  }

  /// Check if feature is premium
  bool isPremiumFeature(String featureId) {
    return premiumFeatures.contains(featureId);
  }

  /// Create from Firebase Remote Config
  factory FeatureConfig.fromRemoteConfig(FirebaseRemoteConfig config) {
    return FeatureConfig(
      // Free modules
      inventoryEnabled: config.getBool('inventory_enabled'),
      ocrScanEnabled: config.getBool('ocr_scan_enabled'),
      notificationsEnabled: config.getBool('notifications_enabled'),
      recipesEnabled: config.getBool('recipes_enabled'),
      dashboardEnabled: config.getBool('dashboard_enabled'),
      authProfileEnabled: config.getBool('auth_profile_enabled'),

      // Premium modules
      mealPlanningEnabled: config.getBool('meal_planning_enabled'),
      aiCoachEnabled: config.getBool('ai_coach_enabled'),
      priceComparatorEnabled: config.getBool('price_comparator_enabled'),
      gamificationEnabled: config.getBool('gamification_enabled'),
      exportSharingEnabled: config.getBool('export_sharing_enabled'),
      familySharingEnabled: config.getBool('family_sharing_enabled'),
      shoppingListEnabled: config.getBool('shopping_list_enabled'),
      nutritionTrackingEnabled: config.getBool('nutrition_tracking_enabled'),

      // Premium features list
      premiumFeatures: _parsePremiumFeatures(
        config.getString('premium_features'),
      ),
    );
  }

  /// Parse premium features from JSON string
  static List<String> _parsePremiumFeatures(String json) {
    try {
      return List<String>.from(jsonDecode(json) as List);
    } catch (e) {
      return [];
    }
  }

  /// Create default configuration (all free features enabled, premium disabled)
  factory FeatureConfig.defaults() {
    return const FeatureConfig(
      // Free modules - enabled
      inventoryEnabled: true,
      ocrScanEnabled: true,
      notificationsEnabled: true,
      recipesEnabled: true,
      dashboardEnabled: true,
      authProfileEnabled: true,

      // Premium modules - disabled
      mealPlanningEnabled: false,
      aiCoachEnabled: false,
      priceComparatorEnabled: false,
      gamificationEnabled: false,
      exportSharingEnabled: false,
      familySharingEnabled: false,
      shoppingListEnabled: false,
      nutritionTrackingEnabled: false,

      // Premium features list
      premiumFeatures: [],
    );
  }

  factory FeatureConfig.fromJson(Map<String, dynamic> json) =>
      _$FeatureConfigFromJson(json);
}
