import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// NOTIFICATIONS PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 3
// ============================================================================

/// Provider pour les notifications actives
final activeNotificationsProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour l'état des notifications (activées/désactivées)
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);

/// Provider pour le délai d'alerte DLC (jours avant expiration)
final dlcAlertDelayProvider = StateProvider<int>((ref) => 2);

/// Provider pour le délai d'alerte DDM (jours avant expiration)
final ddmAlertDelayProvider = StateProvider<int>((ref) => 5);

/// Provider pour les heures silencieuses
final quietHoursEnabledProvider = StateProvider<bool>((ref) => false);
