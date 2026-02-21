import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// MEAL PLANNING PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 9
// ============================================================================

/// Provider pour le plan de repas hebdomadaire
final weeklyMealPlanProvider =
    StateProvider<Map<String, List<Map<String, dynamic>>>>((ref) => {});

/// Provider pour les contraintes du meal plan
final mealPlanConstraintsProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'time_available': 'medium', // 'low', 'medium', 'high'
    'batch_cooking': false,
    'max_prep_time': 60, // minutes
  };
});

/// Provider pour l'état de génération AI
final isGeneratingMealPlanProvider = StateProvider<bool>((ref) => false);

/// Provider pour les portions ajustées
final portionSizesProvider = StateProvider<Map<String, int>>((ref) => {});
