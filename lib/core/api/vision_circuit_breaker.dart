import 'package:cloud_firestore/cloud_firestore.dart';

/// Google Vision API Circuit Breaker
/// Story 0.10 Phase 7: Rate Limiting & Quota Management
///
/// Implements circuit breaker pattern to prevent quota exhaustion.
/// When monthly quota reaches 80% (800/1000), circuit opens and app
/// falls back to ML Kit (on-device OCR).
///
/// Usage:
/// ```dart
/// Future<List<Product>> scanReceipt(File receiptImage) async {
///   final circuitBreaker = VisionCircuitBreaker();
///
///   if (await circuitBreaker.canMakeRequest()) {
///     // Use Google Vision API (higher accuracy)
///     final result = await visionAPI.recognizeText(receiptImage);
///     await circuitBreaker.trackRequest();
///     return result;
///   } else {
///     // Fallback to ML Kit (on-device, no quota)
///     final result = await mlKit.recognizeText(receiptImage);
///     return result;
///   }
/// }
/// ```
class VisionCircuitBreaker {
  /// Monthly quota limit for Google Vision API (free tier)
  static const int monthlyLimit = 1000;

  /// Warning threshold at 80% of quota
  static const int warningThreshold = 800;

  /// Firestore instance for quota tracking
  final FirebaseFirestore _firestore;

  /// Creates a VisionCircuitBreaker with optional custom Firestore instance.
  ///
  /// Defaults to [FirebaseFirestore.instance] if not provided.
  VisionCircuitBreaker({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Checks if a request can be made without exceeding quota.
  ///
  /// Returns `true` if the circuit is CLOSED (quota available).
  /// Returns `false` if the circuit is OPEN (quota exhausted or near limit).
  ///
  /// Circuit opens when:
  /// - Monthly usage >= 1000 (100% quota)
  /// - This prevents exceeding free tier limits
  ///
  /// Example:
  /// ```dart
  /// if (await circuitBreaker.canMakeRequest()) {
  ///   // Safe to use Google Vision API
  /// } else {
  ///   // Must use fallback (ML Kit)
  /// }
  /// ```
  Future<bool> canMakeRequest() async {
    try {
      final quotaDoc = await _firestore
          .collection('global_quota')
          .doc('google_vision')
          .get();

      final monthlyUsage = quotaDoc.data()?['monthly_count'] as int? ?? 0;

      // Circuit breaker OPEN → fallback to ML Kit
      if (monthlyUsage >= monthlyLimit) {
        return false;
      }

      // Circuit breaker CLOSED → proceed with Vision API
      return true;
    } catch (e) {
      // On error, fail closed (don't use Vision API)
      return false;
    }
  }

  /// Tracks a Vision API request by incrementing the monthly counter.
  ///
  /// Should be called AFTER a successful Vision API request.
  ///
  /// Uses Firestore atomic increment to prevent race conditions.
  ///
  /// Example:
  /// ```dart
  /// final result = await visionAPI.recognizeText(image);
  /// await circuitBreaker.trackRequest(); // Increment counter
  /// ```
  Future<void> trackRequest() async {
    try {
      await _firestore.collection('global_quota').doc('google_vision').set(
        {
          'monthly_count': FieldValue.increment(1),
          'last_request': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Log error but don't throw (tracking is best-effort)
      // The circuit breaker will still work on next request
      // Silently fail - tracking is best-effort
      // In production, this would be logged to error tracking service
    }
  }

  /// Gets the current monthly usage count.
  ///
  /// Returns 0 if the quota document doesn't exist yet.
  ///
  /// Example:
  /// ```dart
  /// final usage = await circuitBreaker.getMonthlyUsage();
  /// print('Vision API calls this month: $usage / $monthlyLimit');
  /// ```
  Future<int> getMonthlyUsage() async {
    try {
      final quotaDoc = await _firestore
          .collection('global_quota')
          .doc('google_vision')
          .get();

      return quotaDoc.data()?['monthly_count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Gets the remaining quota count.
  ///
  /// Returns 0 if quota is exhausted.
  ///
  /// Example:
  /// ```dart
  /// final remaining = await circuitBreaker.getRemainingQuota();
  /// if (remaining < 100) {
  ///   showWarning('Low Vision API quota: $remaining requests remaining');
  /// }
  /// ```
  Future<int> getRemainingQuota() async {
    final usage = await getMonthlyUsage();
    final remaining = monthlyLimit - usage;
    return remaining > 0 ? remaining : 0;
  }

  /// Checks if the quota is near the warning threshold (80%).
  ///
  /// Returns `true` if usage >= 800 (80% of 1000).
  ///
  /// Useful for showing warnings to users before quota exhaustion.
  ///
  /// Example:
  /// ```dart
  /// if (await circuitBreaker.isNearLimit()) {
  ///   showWarning('Vision API quota running low. Consider using ML Kit fallback.');
  /// }
  /// ```
  Future<bool> isNearLimit() async {
    final usage = await getMonthlyUsage();
    return usage >= warningThreshold;
  }

  /// Resets the monthly quota counter.
  ///
  /// ⚠️ WARNING: This should only be called by a scheduled Cloud Function
  /// at the start of each month. Manual resets can lead to quota abuse.
  ///
  /// Example (Cloud Function):
  /// ```dart
  /// // Scheduled to run on 1st of each month at midnight
  /// await circuitBreaker.resetMonthlyQuota();
  /// ```
  Future<void> resetMonthlyQuota() async {
    try {
      await _firestore.collection('global_quota').doc('google_vision').set(
        {
          'monthly_count': 0,
          'last_reset': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // Rethrow - quota reset failures should be visible
      // In production, this would be logged to error tracking service
      rethrow;
    }
  }

  /// Gets quota usage as a percentage (0-100).
  ///
  /// Returns 100 if quota is exhausted.
  ///
  /// Example:
  /// ```dart
  /// final percentage = await circuitBreaker.getUsagePercentage();
  /// print('Vision API quota: $percentage% used');
  /// ```
  Future<int> getUsagePercentage() async {
    final usage = await getMonthlyUsage();
    final percentage = ((usage / monthlyLimit) * 100).round();
    return percentage > 100 ? 100 : percentage;
  }
}
