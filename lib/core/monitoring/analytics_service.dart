import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics service provider
/// Story 0.7: Crash Reporting and Performance Monitoring
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Wrapper for Firebase Analytics functionality
///
/// Provides:
/// - Business event tracking (user actions, conversions)
/// - Screen view tracking
/// - User property tracking
/// - Conversion funnel tracking
/// - GDPR-compliant analytics consent management
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the FirebaseAnalyticsObserver for navigation tracking
  ///
  /// Usage in GoRouter:
  /// ```dart
  /// final analyticsService = ref.read(analyticsServiceProvider);
  /// GoRouter(
  ///   observers: [analyticsService.getNavigatorObserver()],
  ///   routes: [...],
  /// );
  /// ```
  FirebaseAnalyticsObserver getNavigatorObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  /// Log a custom event with parameters
  ///
  /// Example:
  /// ```dart
  /// await analytics.logEvent(
  ///   name: 'product_scanned',
  ///   parameters: {
  ///     'scan_method': 'barcode',
  ///     'product_id': 'ABC123',
  ///     'success': true,
  ///   },
  /// );
  /// ```
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  /// Log screen view (automatically called by FirebaseAnalyticsObserver)
  ///
  /// Manual usage (if needed):
  /// ```dart
  /// await analytics.logScreenView(
  ///   screenName: 'InventoryListScreen',
  ///   screenClass: 'InventoryListScreen',
  /// );
  /// ```
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Set user property for segmentation and analysis
  ///
  /// ⚠️ WARNING: Do not store PII (email, phone, etc.)
  ///
  /// Example:
  /// ```dart
  /// await analytics.setUserProperty(
  ///   name: 'user_tier',
  ///   value: 'premium',
  /// );
  /// await analytics.setUserProperty(
  ///   name: 'dietary_preference',
  ///   value: 'vegetarian',
  /// );
  /// ```
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Set user ID for cross-device tracking
  ///
  /// ⚠️ WARNING: Use hashed ID only, no PII (email, phone, etc.)
  ///
  /// Example:
  /// ```dart
  /// final hashedId = userId.hashCode.toString();
  /// await analytics.setUserId(hashedId);
  /// ```
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Clear user ID (e.g., on logout)
  Future<void> clearUserId() async {
    await _analytics.setUserId(id: null);
  }

  /// Enable/disable analytics collection
  ///
  /// Use for GDPR consent management:
  /// - Set to false by default
  /// - Enable only after user grants consent
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  // ========================================================================
  // BUSINESS EVENTS (Story 0.7 - 7 key events)
  // ========================================================================

  /// Event: Product added to inventory
  ///
  /// Tracks how users add products (manual, barcode, OCR)
  Future<void> logProductAdded({
    required String method, // 'manual', 'barcode', 'ocr'
    required String category,
    String? storageLocation,
  }) async {
    await logEvent(
      name: 'product_added',
      parameters: {
        'method': method,
        'category': category,
        ...?(storageLocation != null
            ? {'storage_location': storageLocation}
            : null),
      },
    );
  }

  /// Event: OCR scan performed
  ///
  /// Tracks OCR usage and success rates
  Future<void> logOCRScan({
    required String engine, // 'google_vision', 'ml_kit'
    required bool success,
    int? confidence,
    int? itemsDetected,
  }) async {
    await logEvent(
      name: 'ocr_scan',
      parameters: {
        'engine': engine,
        'success': success,
        ...?(confidence != null ? {'confidence': confidence} : null),
        ...?(itemsDetected != null ? {'items_detected': itemsDetected} : null),
      },
    );
  }

  /// Event: Recipe viewed
  ///
  /// Tracks recipe engagement
  Future<void> logRecipeViewed({
    required String recipeId,
    required String source, // 'search', 'expiring_soon', 'favorites'
    List<String>? dietaryTags,
  }) async {
    await logEvent(
      name: 'recipe_viewed',
      parameters: {
        'recipe_id': recipeId,
        'source': source,
        ...?(dietaryTags != null && dietaryTags.isNotEmpty
            ? {'dietary_tags': dietaryTags.join(',')}
            : null),
      },
    );
  }

  /// Event: Meal plan generated
  ///
  /// Tracks AI meal planning usage
  Future<void> logMealPlanGenerated({
    required String profileType,
    required int durationDays,
    int? recipesGenerated,
  }) async {
    await logEvent(
      name: 'meal_plan_generated',
      parameters: {
        'profile_type': profileType,
        'duration_days': durationDays,
        ...?(recipesGenerated != null
            ? {'recipes_generated': recipesGenerated}
            : null),
      },
    );
  }

  /// Event: Premium feature accessed (conversion funnel)
  ///
  /// Tracks which premium features drive conversions
  Future<void> logPremiumFeatureAccessed({
    required String featureName,
    required bool hasAccess,
  }) async {
    await logEvent(
      name: 'premium_feature_accessed',
      parameters: {'feature_name': featureName, 'has_access': hasAccess},
    );
  }

  /// Event: Food waste prevented
  ///
  /// Tracks anti-waste impact (product consumed before expiration)
  Future<void> logFoodWastePrevented({
    required String category,
    required double estimatedValueEur,
    required double estimatedWeightKg,
  }) async {
    await logEvent(
      name: 'food_waste_prevented',
      parameters: {
        'category': category,
        'value_eur': estimatedValueEur,
        'weight_kg': estimatedWeightKg,
      },
    );
  }

  /// Event: Sync completed
  ///
  /// Tracks offline-first sync health
  Future<void> logSyncCompleted({
    required String phase, // 'upload', 'download', 'conflict_resolution'
    required bool success,
    int? itemsSynced,
    int? durationMs,
  }) async {
    await logEvent(
      name: 'sync_completed',
      parameters: {
        'phase': phase,
        'success': success,
        ...?(itemsSynced != null ? {'items_synced': itemsSynced} : null),
        ...?(durationMs != null ? {'duration_ms': durationMs} : null),
      },
    );
  }

  // ========================================================================
  // PREDEFINED FIREBASE EVENTS (Common conversions)
  // ========================================================================

  /// Log user signup
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log user login
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log app open
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Log tutorial begin
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// Log tutorial complete
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  /// Log search
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  /// Log share
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }
}
