import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// PRICE COMPARATOR PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 12 (Premium feature)
// ============================================================================

/// Provider pour la comparaison de prix entre magasins
final priceComparisonProvider =
    StateProvider<Map<String, Map<String, dynamic>>>((ref) => {});

/// Provider pour les 4 magasins de comparaison
final storesProvider = StateProvider<List<String>>((ref) {
  return ['Carrefour', 'Auchan', 'Leclerc', 'Intermarché'];
});

/// Provider pour la source des données de prix
final priceDataSourceProvider = StateProvider<String>((ref) => 'API');

/// Provider pour la dernière mise à jour des prix
final lastPriceUpdateProvider = StateProvider<DateTime?>((ref) => null);

/// Provider pour le calcul de route optimisé
final optimizedRouteProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider pour la carte interactive
final mapViewEnabledProvider = StateProvider<bool>((ref) => false);
