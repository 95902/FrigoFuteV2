import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// DASHBOARD PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 4
// ============================================================================

/// Provider pour les métriques de gaspillage évité (kg)
final wasteAvoidedKgProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour les métriques de gaspillage évité (€)
final wasteAvoidedEuroProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour l'impact écologique (CO2eq)
final ecologicalImpactProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour les données du graphique temporel
final chartDataProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour le chargement du dashboard
final isDashboardLoadingProvider = StateProvider<bool>((ref) => false);
