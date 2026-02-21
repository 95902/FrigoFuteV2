import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// RECIPES PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 6
// ============================================================================

/// Provider pour la liste de recettes
final recipesListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour les recettes favorites
final favoriteRecipesProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour le filtre de difficulté
final difficultyFilterProvider =
    StateProvider<String?>((ref) => null); // 'easy', 'medium', 'hard'

/// Provider pour le filtre de temps de préparation (minutes)
final preparationTimeFilterProvider = StateProvider<int?>((ref) => null);

/// Provider pour le filtre de régime alimentaire
final dietaryRegimeFilterProvider = StateProvider<String?>((ref) => null);

/// Provider pour les recettes suggérées (produits expirant bientôt)
final suggestedRecipesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
