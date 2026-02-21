import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// FAMILY SHARING PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 14
// ============================================================================

/// Provider pour les membres de la famille
final familyMembersProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour l'inventaire partagé
final sharedInventoryEnabledProvider = StateProvider<bool>((ref) => false);

/// Provider pour les recettes partagées
final sharedRecipesProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour les meal plans partagés
final sharedMealPlansProvider = StateProvider<bool>((ref) => false);

/// Provider pour la sync shopping list en real-time
final realtimeShoppingListSyncProvider = StateProvider<bool>((ref) => false);
