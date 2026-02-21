import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../features/auth_profile/presentation/providers/auth_profile_providers.dart';
import '../../domain/models/onboarding_state.dart';
import 'onboarding_notifier.dart';

// ─── Onboarding State ──────────────────────────────────────────────────────

/// The main onboarding state notifier provider — Story 1.5
///
/// Injected with FirebaseFirestore and current user ID.
/// Falls back to empty string if no user (should not happen in normal flow).
final onboardingStateProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final userId = ref.watch(currentUserIdProvider) ?? '';
  return OnboardingNotifier(firestore, userId);
});

// ─── Onboarding Gate ──────────────────────────────────────────────────────

/// Returns true if user has NOT completed onboarding (needs onboarding)
///
/// Reads `profileType` directly from Firestore to avoid the `getCurrentUser()`
/// bug where UserEntity.fromFirebaseUser() returns empty profileType.
///
/// Used by GoRouter redirect to gate access to protected routes — AC1, AC16
final shouldCompleteOnboardingProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  if (userId.isEmpty) return false;

  final firestore = ref.watch(_firestoreProvider);
  try {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists) return true; // Safety: no doc → needs onboarding

    final data = doc.data() ?? {};
    final profileType = data['profileType'];
    final onboardingCompleted = data['onboardingCompleted'] as bool? ?? false;

    // Onboarding complete if profileType is set AND onboardingCompleted flag is true
    return !onboardingCompleted ||
        profileType == null ||
        profileType.toString().isEmpty;
  } catch (_) {
    return false; // On error, don't force onboarding (avoid blocking app)
  }
});

/// Internal firestore provider (re-export from auth_profile_providers)
final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return ref.watch(firebaseFirestoreProvider);
});
