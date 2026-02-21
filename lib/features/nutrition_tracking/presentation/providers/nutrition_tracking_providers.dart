import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// NUTRITION TRACKING PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 7
// ============================================================================

/// Provider pour le consentement tracking nutrition (double opt-in)
final nutritionTrackingConsentProvider = StateProvider<bool>((ref) => false);

/// Provider pour les logs nutrition quotidiens
final dailyNutritionLogsProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour les statistiques nutrition du jour
final dailyNutritionStatsProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'calories': 0,
    'proteins': 0.0,
    'carbs': 0.0,
    'fats': 0.0,
  };
});

/// Provider pour l'historique hebdomadaire
final weeklyNutritionHistoryProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour l'historique mensuel
final monthlyNutritionHistoryProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
