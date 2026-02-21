import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'exceptions/quota_exceptions.dart';
import 'models/quota_info.dart';

/// Quota Service
/// Story 0.10 Phase 7: Rate Limiting & Quota Management
///
/// Centralized service for tracking API quota usage across all APIs.
/// Integrates with Firestore `/users/{userId}/quota/{apiName}` collection.
///
/// Features:
/// - Track daily/monthly quota usage
/// - Check quota availability before API calls
/// - Automatic quota limit enforcement
/// - Premium user handling (unlimited quota)
/// - User-friendly error messages
///
/// Usage:
/// ```dart
/// final quotaService = QuotaService();
///
/// // Check if request can be made
/// await quotaService.checkQuota(
///   apiName: 'gemini',
///   dailyLimit: 100,
/// );
///
/// // Track successful request
/// await quotaService.trackRequest(apiName: 'gemini');
/// ```
class QuotaService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  QuotaService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Gets the quota reference for a specific API.
  ///
  /// Throws [StateError] if user is not authenticated.
  DocumentReference _getQuotaRef(String apiName) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User must be authenticated to access quota');
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quota')
        .doc(apiName);
  }

  /// Gets quota information for a specific API.
  ///
  /// Returns [QuotaInfo] with current usage counts.
  /// Creates a new quota document if it doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final quotaInfo = await quotaService.getQuota(
  ///   apiName: 'gemini',
  ///   dailyLimit: 100,
  /// );
  /// print('Daily usage: ${quotaInfo.todayCount}/${quotaInfo.dailyLimit}');
  /// ```
  Future<QuotaInfo> getQuota({
    required String apiName,
    int? dailyLimit,
    int? monthlyLimit,
  }) async {
    final quotaRef = _getQuotaRef(apiName);
    final doc = await quotaRef.get();

    if (!doc.exists) {
      // Create new quota document with defaults
      await quotaRef.set({
        'today_count': 0,
        'monthly_count': 0,
        'last_daily_reset': FieldValue.serverTimestamp(),
        'last_monthly_reset': FieldValue.serverTimestamp(),
        'is_premium': false,
      });

      // Return fresh quota info
      return QuotaInfo(
        apiName: apiName,
        todayCount: 0,
        monthlyCount: 0,
        isPremium: false,
        dailyLimit: dailyLimit,
        monthlyLimit: monthlyLimit,
      );
    }

    return QuotaInfo.fromFirestore(
      doc,
      apiName,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );
  }

  /// Checks if a request can be made within quota limits.
  ///
  /// Throws [QuotaExceededException] if quota is exhausted.
  /// Returns silently if quota is available.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await quotaService.checkQuota(
  ///     apiName: 'gemini',
  ///     dailyLimit: 100,
  ///   );
  ///   // Quota available, proceed with API call
  /// } on QuotaExceededException catch (e) {
  ///   showError(e.message);
  /// }
  /// ```
  Future<void> checkQuota({
    required String apiName,
    int? dailyLimit,
    int? monthlyLimit,
  }) async {
    final quotaInfo = await getQuota(
      apiName: apiName,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );

    // Premium users have unlimited quota
    if (quotaInfo.isPremium) return;

    // Check daily quota
    if (dailyLimit != null && quotaInfo.todayCount >= dailyLimit) {
      throw QuotaExceededException(
        'Daily quota exhausted for $apiName. Upgrade to Premium for unlimited access.',
        apiName: apiName,
        quotaType: QuotaType.daily,
        limit: dailyLimit,
        current: quotaInfo.todayCount,
      );
    }

    // Check monthly quota
    if (monthlyLimit != null && quotaInfo.monthlyCount >= monthlyLimit) {
      throw QuotaExceededException(
        'Monthly quota exhausted for $apiName. Please wait for quota reset.',
        apiName: apiName,
        quotaType: QuotaType.monthly,
        limit: monthlyLimit,
        current: quotaInfo.monthlyCount,
      );
    }
  }

  /// Tracks a successful API request by incrementing counters.
  ///
  /// Uses Firestore atomic increment to prevent race conditions.
  ///
  /// Example:
  /// ```dart
  /// final result = await geminiAPI.analyzeMeal(image);
  /// await quotaService.trackRequest(apiName: 'gemini');
  /// ```
  Future<void> trackRequest({required String apiName}) async {
    final quotaRef = _getQuotaRef(apiName);

    await quotaRef.set(
      {
        'today_count': FieldValue.increment(1),
        'monthly_count': FieldValue.increment(1),
        'last_request': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Resets daily quota counters for a specific API.
  ///
  /// ⚠️ WARNING: This should only be called by a scheduled Cloud Function
  /// at midnight each day. Manual resets can lead to quota abuse.
  ///
  /// Example (Cloud Function):
  /// ```dart
  /// // Scheduled to run daily at midnight
  /// await quotaService.resetDailyQuota(apiName: 'gemini');
  /// ```
  Future<void> resetDailyQuota({required String apiName}) async {
    final quotaRef = _getQuotaRef(apiName);

    await quotaRef.set(
      {
        'today_count': 0,
        'last_daily_reset': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Resets monthly quota counters for a specific API.
  ///
  /// ⚠️ WARNING: This should only be called by a scheduled Cloud Function
  /// at the start of each month. Manual resets can lead to quota abuse.
  ///
  /// Example (Cloud Function):
  /// ```dart
  /// // Scheduled to run on 1st of each month at midnight
  /// await quotaService.resetMonthlyQuota(apiName: 'google_vision');
  /// ```
  Future<void> resetMonthlyQuota({required String apiName}) async {
    final quotaRef = _getQuotaRef(apiName);

    await quotaRef.set(
      {
        'monthly_count': 0,
        'last_monthly_reset': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Upgrades user to premium (unlimited quota).
  ///
  /// Should be called after successful premium subscription payment.
  ///
  /// Example:
  /// ```dart
  /// await quotaService.setPremiumStatus(isPremium: true);
  /// ```
  Future<void> setPremiumStatus({required bool isPremium}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw StateError('User must be authenticated to set premium status');
    }

    // Update all quota documents for this user
    final quotaDocs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('quota')
        .get();

    final batch = _firestore.batch();

    for (final doc in quotaDocs.docs) {
      batch.set(
        doc.reference,
        {'is_premium': isPremium},
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// Gets remaining quota count for a specific API.
  ///
  /// Returns null if user is premium (unlimited quota).
  ///
  /// Example:
  /// ```dart
  /// final remaining = await quotaService.getRemainingQuota(
  ///   apiName: 'gemini',
  ///   dailyLimit: 100,
  /// );
  ///
  /// if (remaining != null && remaining < 10) {
  ///   showWarning('Low quota: $remaining requests remaining today');
  /// }
  /// ```
  Future<int?> getRemainingQuota({
    required String apiName,
    int? dailyLimit,
    int? monthlyLimit,
  }) async {
    final quotaInfo = await getQuota(
      apiName: apiName,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );

    if (quotaInfo.isPremium) return null;

    // Return daily remaining if daily limit exists
    if (dailyLimit != null) {
      return quotaInfo.getRemainingDailyQuota();
    }

    // Return monthly remaining if monthly limit exists
    if (monthlyLimit != null) {
      return quotaInfo.getRemainingMonthlyQuota();
    }

    return null;
  }

  /// Checks if quota is near limit (>80% usage).
  ///
  /// Useful for showing warnings to users before quota exhaustion.
  ///
  /// Example:
  /// ```dart
  /// if (await quotaService.isNearLimit(
  ///   apiName: 'gemini',
  ///   dailyLimit: 100,
  /// )) {
  ///   showWarning('Gemini API quota running low. Consider upgrading to Premium.');
  /// }
  /// ```
  Future<bool> isNearLimit({
    required String apiName,
    int? dailyLimit,
    int? monthlyLimit,
  }) async {
    final quotaInfo = await getQuota(
      apiName: apiName,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );

    if (quotaInfo.isPremium) return false;

    // Check daily usage (80% threshold)
    if (dailyLimit != null) {
      final percentage = quotaInfo.getDailyUsagePercentage();
      return percentage != null && percentage >= 80;
    }

    // Check monthly usage (80% threshold)
    if (monthlyLimit != null) {
      final percentage = quotaInfo.getMonthlyUsagePercentage();
      return percentage != null && percentage >= 80;
    }

    return false;
  }

  /// Gets quota usage percentage (0-100).
  ///
  /// Returns null if user is premium.
  ///
  /// Example:
  /// ```dart
  /// final percentage = await quotaService.getUsagePercentage(
  ///   apiName: 'gemini',
  ///   dailyLimit: 100,
  /// );
  ///
  /// if (percentage != null) {
  ///   print('Gemini quota: $percentage% used');
  /// }
  /// ```
  Future<int?> getUsagePercentage({
    required String apiName,
    int? dailyLimit,
    int? monthlyLimit,
  }) async {
    final quotaInfo = await getQuota(
      apiName: apiName,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );

    if (quotaInfo.isPremium) return null;

    // Return daily percentage if daily limit exists
    if (dailyLimit != null) {
      return quotaInfo.getDailyUsagePercentage();
    }

    // Return monthly percentage if monthly limit exists
    if (monthlyLimit != null) {
      return quotaInfo.getMonthlyUsagePercentage();
    }

    return null;
  }
}
