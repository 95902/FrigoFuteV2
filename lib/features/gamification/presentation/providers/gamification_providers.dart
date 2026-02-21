import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// GAMIFICATION PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 13
// ============================================================================

/// Provider pour les achievements débloqués
final unlockedAchievementsProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour les streaks actifs
final activeStreaksProvider = StateProvider<Map<String, int>>((ref) {
  return {
    'days_without_waste': 0,
    'days_cooked_at_home': 0,
  };
});

/// Provider pour le leaderboard des amis (opt-in)
final friendsLeaderboardProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour l'opt-in au leaderboard
final leaderboardOptInProvider = StateProvider<bool>((ref) => false);

/// Provider pour les challenges actifs
final activeChallengesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour les points accumulés
final totalPointsProvider = StateProvider<int>((ref) => 0);
