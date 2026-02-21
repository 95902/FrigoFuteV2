import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

/// Subscription status model
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Tracks user's premium subscription status and active features
@freezed
abstract class SubscriptionStatus with _$SubscriptionStatus {
  const SubscriptionStatus._();

  const factory SubscriptionStatus({
    /// Whether user has premium subscription
    required bool isPremium,

    /// List of premium features user has access to
    required List<String> activePremiumFeatures,

    /// Trial end date (null if not on trial)
    DateTime? trialEndDate,

    /// Subscription end date (null if no active subscription)
    DateTime? subscriptionEndDate,

    /// Subscription plan ID (e.g., 'premium_monthly', 'premium_yearly')
    String? planId,
  }) = _SubscriptionStatus;

  /// Free user with no premium access
  factory SubscriptionStatus.free() {
    return const SubscriptionStatus(
      isPremium: false,
      activePremiumFeatures: [],
    );
  }

  /// Loading state
  factory SubscriptionStatus.loading() {
    return const SubscriptionStatus(
      isPremium: false,
      activePremiumFeatures: [],
    );
  }

  /// Premium user with all features
  factory SubscriptionStatus.premium({
    DateTime? trialEndDate,
    DateTime? subscriptionEndDate,
    String? planId,
  }) {
    return SubscriptionStatus(
      isPremium: true,
      activePremiumFeatures: const [
        'meal_planning',
        'ai_coach',
        'price_comparator',
        'gamification',
        'export_sharing',
        'family_sharing',
        'shopping_list',
        'nutrition_tracking',
      ],
      trialEndDate: trialEndDate,
      subscriptionEndDate: subscriptionEndDate,
      planId: planId,
    );
  }

  /// Check if user has access to specific premium feature
  ///
  /// Example:
  /// ```dart
  /// if (subscription.hasFeature('meal_planning')) {
  ///   // User has access to meal planning
  /// }
  /// ```
  bool hasFeature(String featureId) {
    return activePremiumFeatures.contains(featureId);
  }

  /// Check if trial is active
  bool get isTrialActive {
    if (trialEndDate == null) return false;
    return DateTime.now().isBefore(trialEndDate!);
  }

  /// Check if subscription is active (not expired)
  bool get isSubscriptionActive {
    if (!isPremium) return false;
    if (subscriptionEndDate == null) return true; // Lifetime subscription
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  /// Get days remaining in trial
  int? get trialDaysRemaining {
    if (trialEndDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(trialEndDate!)) return 0;
    return trialEndDate!.difference(now).inDays;
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);
}
