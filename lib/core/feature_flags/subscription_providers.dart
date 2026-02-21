import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_providers.dart';
import 'models/subscription_status.dart';

/// Subscription status for current user
/// Story 0.8: Configure Feature Flags via Firebase Remote Config
///
/// Fetches subscription status from Firestore users/{userId} collection
///
/// Example:
/// ```dart
/// final subscription = ref.watch(subscriptionStatusProvider);
/// subscription.when(
///   data: (status) => Text('Premium: ${status.isPremium}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(SubscriptionStatus.free());
      }

      // Fetch from Firestore users/{userId}
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              return SubscriptionStatus.free();
            }

            final data = doc.data()!;
            return SubscriptionStatus(
              isPremium: data['isPremium'] as bool? ?? false,
              activePremiumFeatures: List<String>.from(
                data['premiumFeatures'] as List? ?? [],
              ),
              trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
              subscriptionEndDate: (data['subscriptionEndDate'] as Timestamp?)
                  ?.toDate(),
              planId: data['planId'] as String?,
            );
          });
    },
    loading: () => Stream.value(SubscriptionStatus.loading()),
    error: (error, stackTrace) => Stream.value(SubscriptionStatus.free()),
  );
});

/// User subscription from Firestore (family provider)
///
/// Fetches subscription data for specific user ID
///
/// Example:
/// ```dart
/// final subscription = ref.watch(userSubscriptionProvider('user_123'));
/// ```
final userSubscriptionProvider =
    StreamProvider.family<SubscriptionStatus, String>((ref, userId) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              return SubscriptionStatus.free();
            }

            final data = doc.data()!;
            return SubscriptionStatus(
              isPremium: data['isPremium'] as bool? ?? false,
              activePremiumFeatures: List<String>.from(
                data['premiumFeatures'] as List? ?? [],
              ),
              trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
              subscriptionEndDate: (data['subscriptionEndDate'] as Timestamp?)
                  ?.toDate(),
              planId: data['planId'] as String?,
            );
          });
    });
