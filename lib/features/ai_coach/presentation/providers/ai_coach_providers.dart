import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// AI COACH PROVIDERS - Story 0.4 Placeholder
// Full implementation: Epic 11 (Premium feature)
// ============================================================================

/// Provider pour les messages du chat nutrition
final chatMessagesProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

/// Provider pour l'état d'envoi de message
final isSendingMessageProvider = StateProvider<bool>((ref) => false);

/// Provider pour l'analyse de photo de repas
final mealPhotoAnalysisProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

/// Provider pour le niveau de confiance de l'analyse photo (0.0 - 1.0)
final mealAnalysisConfidenceProvider = StateProvider<double>((ref) => 0.0);

/// Provider pour le quota API Gemini restant
final geminiApiQuotaProvider = StateProvider<int>((ref) => 100);
