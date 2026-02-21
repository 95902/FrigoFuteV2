import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// NUTRITION PROFILES PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 8
// ============================================================================

/// Provider pour le profil nutritionnel sélectionné
final selectedNutritionProfileProvider = StateProvider<String?>((ref) => null);

/// Provider pour le TDEE calculé
final tdeeProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour le BMR calculé
final bmrProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour les objectifs macros
final macroTargetsProvider = StateProvider<Map<String, double>>((ref) {
  return {
    'proteins': 0.0,
    'carbs': 0.0,
    'fats': 0.0,
  };
});

/// Provider pour les 12 profils prédéfinis
final availableProfilesProvider = StateProvider<List<String>>((ref) {
  return [
    'weight_loss',
    'muscle_gain',
    'maintenance',
    'diabetic',
    'heart_health',
    'high_protein',
    'low_carb',
    'balanced',
    'vegetarian',
    'vegan',
    'keto',
    'paleo',
  ];
});
