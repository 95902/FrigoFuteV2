import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../feature_flags/subscription_providers.dart';
import 'paywall_widget.dart';

/// Guard widget that checks if user has access to premium feature
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Shows child widget if user has access, otherwise shows paywall
///
/// Example:
/// ```dart
/// PremiumFeatureGuard(
///   featureId: 'meal_planning',
///   child: MealPlanningScreen(),
/// )
/// ```
class PremiumFeatureGuard extends ConsumerWidget {
  /// Premium feature ID to check
  final String featureId;

  /// Widget to show if user has access
  final Widget child;

  /// Custom fallback widget (defaults to PaywallWidget)
  final Widget? fallback;

  const PremiumFeatureGuard({
    required this.featureId,
    required this.child,
    this.fallback,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionStatusProvider);

    return subscription.when(
      data: (status) {
        // Check if user has access to this feature
        if (status.hasFeature(featureId) || status.isPremium) {
          return child;
        } else {
          // Show paywall or custom fallback
          return fallback ??
              PaywallWidget(
                featureId: featureId,
                featureName: _getFeatureName(featureId),
              );
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(subscriptionStatusProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get localized feature name
  String _getFeatureName(String featureId) {
    const Map<String, String> featureNames = {
      'meal_planning': 'Planning Repas IA',
      'ai_coach': 'Coach Nutrition IA',
      'price_comparator': 'Comparateur Prix',
      'gamification': 'Gamification',
      'export_sharing': 'Export & Partage',
      'family_sharing': 'Partage Famille',
      'shopping_list': 'Liste Courses',
      'nutrition_tracking': 'Suivi Nutrition',
    };
    return featureNames[featureId] ?? featureId;
  }
}
