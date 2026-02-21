import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_config_service.dart';
import 'models/feature_config.dart';

/// Remote Config service singleton provider
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Feature flags configuration stream provider
///
/// Provides real-time updates when feature flags change on the server
///
/// Example:
/// ```dart
/// final config = ref.watch(featureFlagsProvider);
/// config.when(
///   data: (config) => Text('Inventory: ${config.inventoryEnabled}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final featureFlagsProvider = StreamProvider<FeatureConfig>((ref) {
  final service = ref.watch(remoteConfigServiceProvider);
  return service.configStream;
});

/// Check if user has premium access
///
/// Example:
/// ```dart
/// final isPremium = ref.watch(isPremiumProvider);
/// if (isPremium) {
///   // Show premium features
/// }
/// ```
final isPremiumProvider = Provider<bool>((ref) {
  final config = ref.watch(featureFlagsProvider);
  return config.maybeWhen(
    data: (config) => config.isPremium,
    orElse: () => false,
  );
});

/// Check if specific feature is enabled (family provider)
///
/// Example:
/// ```dart
/// final isInventoryEnabled = ref.watch(featureEnabledProvider('inventory'));
/// if (isInventoryEnabled) {
///   // Show inventory feature
/// }
/// ```
final featureEnabledProvider = Provider.family<bool, String>((ref, featureId) {
  final config = ref.watch(featureFlagsProvider);
  return config.maybeWhen(
    data: (config) => config.isEnabled(featureId),
    orElse: () => false,
  );
});
