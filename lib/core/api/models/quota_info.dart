import 'package:cloud_firestore/cloud_firestore.dart';

/// Quota Information Model
/// Story 0.10 Phase 7: Rate Limiting & Quota Management
///
/// Represents API quota tracking data stored in Firestore.
/// Used for tracking Gemini AI, Google Vision, and other API usage.
class QuotaInfo {
  /// API name (e.g., 'gemini', 'google_vision')
  final String apiName;

  /// Current daily usage count
  final int todayCount;

  /// Current monthly usage count (for Vision API)
  final int monthlyCount;

  /// Last request timestamp
  final DateTime? lastRequest;

  /// Last daily reset timestamp
  final DateTime? lastDailyReset;

  /// Last monthly reset timestamp
  final DateTime? lastMonthlyReset;

  /// Whether user has premium subscription (unlimited quota)
  final bool isPremium;

  /// Daily quota limit (free tier)
  /// - Gemini: 100 requests/day
  /// - Vision: No daily limit (monthly only)
  final int? dailyLimit;

  /// Monthly quota limit
  /// - Gemini: No monthly limit (daily only)
  /// - Vision: 1000 requests/month
  final int? monthlyLimit;

  const QuotaInfo({
    required this.apiName,
    required this.todayCount,
    required this.monthlyCount,
    this.lastRequest,
    this.lastDailyReset,
    this.lastMonthlyReset,
    this.isPremium = false,
    this.dailyLimit,
    this.monthlyLimit,
  });

  /// Creates a QuotaInfo from Firestore document data.
  ///
  /// Example:
  /// ```dart
  /// final doc = await firestore.collection('users').doc(uid).collection('quota').doc('gemini').get();
  /// final quotaInfo = QuotaInfo.fromFirestore(doc, 'gemini');
  /// ```
  factory QuotaInfo.fromFirestore(
    DocumentSnapshot doc,
    String apiName, {
    int? dailyLimit,
    int? monthlyLimit,
  }) {
    final data = doc.data() as Map<String, dynamic>?;

    return QuotaInfo(
      apiName: apiName,
      todayCount: data?['today_count'] as int? ?? 0,
      monthlyCount: data?['monthly_count'] as int? ?? 0,
      lastRequest: (data?['last_request'] as Timestamp?)?.toDate(),
      lastDailyReset: (data?['last_daily_reset'] as Timestamp?)?.toDate(),
      lastMonthlyReset: (data?['last_monthly_reset'] as Timestamp?)?.toDate(),
      isPremium: data?['is_premium'] as bool? ?? false,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );
  }

  /// Converts QuotaInfo to Firestore document data.
  ///
  /// Example:
  /// ```dart
  /// await firestore.collection('users').doc(uid).collection('quota').doc('gemini').set(
  ///   quotaInfo.toFirestore(),
  /// );
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      'today_count': todayCount,
      'monthly_count': monthlyCount,
      if (lastRequest != null) 'last_request': Timestamp.fromDate(lastRequest!),
      if (lastDailyReset != null)
        'last_daily_reset': Timestamp.fromDate(lastDailyReset!),
      if (lastMonthlyReset != null)
        'last_monthly_reset': Timestamp.fromDate(lastMonthlyReset!),
      'is_premium': isPremium,
    };
  }

  /// Gets remaining daily quota.
  ///
  /// Returns null if no daily limit (premium or API without daily limit).
  ///
  /// Example:
  /// ```dart
  /// final remaining = quotaInfo.getRemainingDailyQuota();
  /// if (remaining == 0) {
  ///   showError('Daily quota exhausted');
  /// }
  /// ```
  int? getRemainingDailyQuota() {
    if (isPremium || dailyLimit == null) return null;
    final remaining = dailyLimit! - todayCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Gets remaining monthly quota.
  ///
  /// Returns null if no monthly limit (premium or API without monthly limit).
  ///
  /// Example:
  /// ```dart
  /// final remaining = quotaInfo.getRemainingMonthlyQuota();
  /// if (remaining != null && remaining < 100) {
  ///   showWarning('Low monthly quota: $remaining requests remaining');
  /// }
  /// ```
  int? getRemainingMonthlyQuota() {
    if (isPremium || monthlyLimit == null) return null;
    final remaining = monthlyLimit! - monthlyCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Checks if daily quota is exhausted.
  ///
  /// Returns false if no daily limit (premium or API without daily limit).
  ///
  /// Example:
  /// ```dart
  /// if (quotaInfo.isDailyQuotaExhausted()) {
  ///   throw QuotaExceededException('Daily quota exhausted');
  /// }
  /// ```
  bool isDailyQuotaExhausted() {
    if (isPremium || dailyLimit == null) return false;
    return todayCount >= dailyLimit!;
  }

  /// Checks if monthly quota is exhausted.
  ///
  /// Returns false if no monthly limit (premium or API without monthly limit).
  ///
  /// Example:
  /// ```dart
  /// if (quotaInfo.isMonthlyQuotaExhausted()) {
  ///   throw QuotaExceededException('Monthly quota exhausted');
  /// }
  /// ```
  bool isMonthlyQuotaExhausted() {
    if (isPremium || monthlyLimit == null) return false;
    return monthlyCount >= monthlyLimit!;
  }

  /// Gets daily usage percentage (0-100).
  ///
  /// Returns null if no daily limit.
  ///
  /// Example:
  /// ```dart
  /// final percentage = quotaInfo.getDailyUsagePercentage();
  /// if (percentage != null && percentage > 80) {
  ///   showWarning('Daily quota running low: $percentage% used');
  /// }
  /// ```
  int? getDailyUsagePercentage() {
    if (dailyLimit == null || dailyLimit == 0) return null;
    final percentage = ((todayCount / dailyLimit!) * 100).round();
    return percentage > 100 ? 100 : percentage;
  }

  /// Gets monthly usage percentage (0-100).
  ///
  /// Returns null if no monthly limit.
  ///
  /// Example:
  /// ```dart
  /// final percentage = quotaInfo.getMonthlyUsagePercentage();
  /// if (percentage != null && percentage > 80) {
  ///   showWarning('Monthly quota running low: $percentage% used');
  /// }
  /// ```
  int? getMonthlyUsagePercentage() {
    if (monthlyLimit == null || monthlyLimit == 0) return null;
    final percentage = ((monthlyCount / monthlyLimit!) * 100).round();
    return percentage > 100 ? 100 : percentage;
  }

  /// Creates a copy with updated fields.
  QuotaInfo copyWith({
    String? apiName,
    int? todayCount,
    int? monthlyCount,
    DateTime? lastRequest,
    DateTime? lastDailyReset,
    DateTime? lastMonthlyReset,
    bool? isPremium,
    int? dailyLimit,
    int? monthlyLimit,
  }) {
    return QuotaInfo(
      apiName: apiName ?? this.apiName,
      todayCount: todayCount ?? this.todayCount,
      monthlyCount: monthlyCount ?? this.monthlyCount,
      lastRequest: lastRequest ?? this.lastRequest,
      lastDailyReset: lastDailyReset ?? this.lastDailyReset,
      lastMonthlyReset: lastMonthlyReset ?? this.lastMonthlyReset,
      isPremium: isPremium ?? this.isPremium,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  @override
  String toString() {
    return 'QuotaInfo('
        'apiName: $apiName, '
        'todayCount: $todayCount, '
        'monthlyCount: $monthlyCount, '
        'isPremium: $isPremium, '
        'dailyLimit: $dailyLimit, '
        'monthlyLimit: $monthlyLimit'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuotaInfo &&
        other.apiName == apiName &&
        other.todayCount == todayCount &&
        other.monthlyCount == monthlyCount &&
        other.lastRequest == lastRequest &&
        other.lastDailyReset == lastDailyReset &&
        other.lastMonthlyReset == lastMonthlyReset &&
        other.isPremium == isPremium &&
        other.dailyLimit == dailyLimit &&
        other.monthlyLimit == monthlyLimit;
  }

  @override
  int get hashCode {
    return apiName.hashCode ^
        todayCount.hashCode ^
        monthlyCount.hashCode ^
        lastRequest.hashCode ^
        lastDailyReset.hashCode ^
        lastMonthlyReset.hashCode ^
        isPremium.hashCode ^
        dailyLimit.hashCode ^
        monthlyLimit.hashCode;
  }
}
