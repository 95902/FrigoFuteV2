import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// SHOPPING LIST PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 10
// ============================================================================

/// Provider pour la liste de courses
final shoppingListProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour les items cochés
final checkedItemsProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour la génération automatique depuis meal plan
final autoGenerateFromMealPlanProvider = StateProvider<bool>((ref) => true);

/// Provider pour la déduction de l'inventaire existant
final deductInventoryProvider = StateProvider<bool>((ref) => true);
