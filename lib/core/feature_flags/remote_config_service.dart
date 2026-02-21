import 'dart:async';
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'models/feature_config.dart';

/// Singleton service for Firebase Remote Config
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Provides:
/// - Dynamic feature flag management
/// - 14 feature flags (6 free + 8 premium)
/// - 5-second fetch timeout with cache fallback
/// - Real-time config updates stream
/// - Freemium model support
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  factory RemoteConfigService() => _instance;

  RemoteConfigService._internal();

  late FirebaseRemoteConfig _remoteConfig;
  final _configStreamController = StreamController<FeatureConfig>.broadcast();

  /// Stream of feature config updates
  Stream<FeatureConfig> get configStream => _configStreamController.stream;

  /// Initialize Remote Config with defaults and fetch
  ///
  /// - Sets 5-second fetch timeout (AC #7)
  /// - Sets 12-hour minimum fetch interval (cache duration)
  /// - Sets default values for all 14 feature flags (AC #3)
  /// - Fetches from server with fallback to cache (AC #4, #7)
  /// - Listens for real-time updates (AC #5)
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await RemoteConfigService().initialize();
  ///   print('Remote Config initialized');
  /// } catch (e) {
  ///   print('Failed to initialize: $e');
  ///   // Continue with default values
  /// }
  /// ```
  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Configure settings (AC #7: 5 second timeout)
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 5), // AC #7
        minimumFetchInterval: const Duration(hours: 12), // Cache 12 hours
      ),
    );

    // Set default values (AC #3: 14 feature flags with defaults)
    await _remoteConfig.setDefaults(_defaultValues);

    // Fetch and activate with timeout (AC #4, #7)
    try {
      final activated = await _remoteConfig.fetchAndActivate().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('⚠️ Remote Config fetch timeout - using cached values');
          }
          return false; // Fallback to cache/defaults
        },
      );

      if (kDebugMode) {
        if (activated) {
          debugPrint('✅ Remote Config initialized with new values from server');
        } else {
          debugPrint('✅ Remote Config initialized with cached values');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Remote Config fetch failed: $e - using default values');
      }
      // Continue with defaults - don't throw
    }

    // Listen for config updates (AC #5: server-side updates)
    _remoteConfig.onConfigUpdated.listen((event) async {
      await _remoteConfig.activate();
      _configStreamController.add(getFeatureConfig());

      if (kDebugMode) {
        debugPrint('🔄 Remote Config updated from server');
      }
    });

    // Emit initial config
    _configStreamController.add(getFeatureConfig());
  }

  /// Get current feature configuration
  FeatureConfig getFeatureConfig() {
    return FeatureConfig.fromRemoteConfig(_remoteConfig);
  }

  /// Check if specific feature is enabled
  ///
  /// Example:
  /// ```dart
  /// if (remoteConfigService.isFeatureEnabled('inventory')) {
  ///   // Feature is enabled
  /// }
  /// ```
  bool isFeatureEnabled(String featureId) {
    return _remoteConfig.getBool('${featureId}_enabled');
  }

  /// Get list of premium features
  List<String> getPremiumFeatures() {
    try {
      final json = _remoteConfig.getString('premium_features');
      return List<String>.from(jsonDecode(json) as List);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing premium_features: $e');
      }
      return _defaultPremiumFeatures;
    }
  }

  /// Dispose resources
  void dispose() {
    _configStreamController.close();
  }

  /// Default values for all feature flags (AC #3)
  ///
  /// 6 Free modules - enabled by default
  /// 8 Premium modules - disabled by default
  static final Map<String, dynamic> _defaultValues = {
    // Free modules (6) - enabled by default
    'inventory_enabled': true,
    'ocr_scan_enabled': true,
    'notifications_enabled': true,
    'recipes_enabled': true,
    'dashboard_enabled': true,
    'auth_profile_enabled': true,

    // Premium modules (8) - disabled by default
    'meal_planning_enabled': false,
    'ai_coach_enabled': false,
    'price_comparator_enabled': false,
    'gamification_enabled': false,
    'export_sharing_enabled': false,
    'family_sharing_enabled': false,
    'shopping_list_enabled': false,
    'nutrition_tracking_enabled': false,

    // Premium features list
    'premium_features': jsonEncode(_defaultPremiumFeatures),
  };

  static const List<String> _defaultPremiumFeatures = [
    'meal_planning',
    'ai_coach',
    'price_comparator',
    'gamification',
    'export_sharing',
    'family_sharing',
    'shopping_list',
    'nutrition_tracking',
  ];
}
