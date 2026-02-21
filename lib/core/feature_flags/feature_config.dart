/// Configuration des feature flags
/// Story 0.4: Placeholder implementation
/// Story 0.8: Full implementation avec Firebase Remote Config
class FeatureConfig {
  final bool isPremium;
  final Map<String, bool> features;

  const FeatureConfig({
    this.isPremium = false,
    this.features = const {},
  });

  /// Check if a specific feature is enabled
  bool isFeatureEnabled(String featureName) {
    return features[featureName] ?? false;
  }

  /// Factory placeholder - Story 0.8 will implement from Remote Config
  factory FeatureConfig.fromRemoteConfig(dynamic remoteConfig) {
    // Placeholder implementation
    return const FeatureConfig(
      isPremium: false,
      features: {
        'ocr_scanning': true,
        'nutrition_tracking': true,
        'ai_coach': false, // Premium feature
        'price_comparison': false, // Premium feature
      },
    );
  }

  /// Default configuration (free tier)
  factory FeatureConfig.defaults() {
    return const FeatureConfig(
      isPremium: false,
      features: {
        'inventory': true,
        'recipes': true,
        'notifications': true,
        'dashboard': true,
        'ocr_scanning': true,
        'nutrition_tracking': true,
        'meal_planning': false, // Premium
        'ai_coach': false, // Premium
        'price_comparison': false, // Premium
        'gamification': true,
      },
    );
  }
}
