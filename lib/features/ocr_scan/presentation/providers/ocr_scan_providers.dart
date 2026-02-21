import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// OCR SCAN PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 5
// ============================================================================

/// Provider pour le résultat du dernier scan OCR
final lastOcrScanResultProvider = StateProvider<String?>((ref) => null);

/// Provider pour l'état de scanning (true si en cours)
final isScanningProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'historique des scans
final scanHistoryProvider = StateProvider<List<String>>((ref) => []);

/// Provider pour le niveau de confiance du dernier scan (0.0 - 1.0)
final scanConfidenceProvider = StateProvider<double>((ref) => 0.0);
