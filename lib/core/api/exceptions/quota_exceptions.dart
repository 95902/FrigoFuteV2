/// Quota Exception Base Class
/// Story 0.10 Phase 7: Rate Limiting & Quota Management
///
/// Base exception for all quota-related errors.
abstract class QuotaException implements Exception {
  final String message;
  final String? apiName;

  const QuotaException(this.message, {this.apiName});

  @override
  String toString() => 'QuotaException: $message';
}

/// Quota Exceeded Exception
///
/// Thrown when API quota limit is reached.
///
/// Example:
/// ```dart
/// if (quotaInfo.isDailyQuotaExhausted()) {
///   throw QuotaExceededException(
///     'Daily quota exhausted. Upgrade to Premium for unlimited access.',
///     apiName: 'gemini',
///     quotaType: QuotaType.daily,
///     limit: 100,
///     current: 100,
///   );
/// }
/// ```
class QuotaExceededException extends QuotaException {
  final QuotaType quotaType;
  final int limit;
  final int current;

  const QuotaExceededException(
    super.message, {
    required this.quotaType,
    required this.limit,
    required this.current,
    super.apiName,
  });

  @override
  String toString() =>
      'QuotaExceededException: $message (${quotaType.name} limit: $limit, current: $current)';
}

/// Rate Limit Exceeded Exception
///
/// Thrown when rate limit is exceeded (requests per second/minute).
///
/// Example:
/// ```dart
/// throw RateLimitExceededException(
///   'Too many requests. Please wait before trying again.',
///   apiName: 'gemini',
///   retryAfter: Duration(seconds: 2),
/// );
/// ```
class RateLimitExceededException extends QuotaException {
  final Duration retryAfter;

  const RateLimitExceededException(
    super.message, {
    required this.retryAfter,
    super.apiName,
  });

  @override
  String toString() =>
      'RateLimitExceededException: $message (retry after: ${retryAfter.inSeconds}s)';
}

/// Circuit Breaker Open Exception
///
/// Thrown when circuit breaker is open (quota threshold reached).
///
/// Example:
/// ```dart
/// if (!await circuitBreaker.canMakeRequest()) {
///   throw CircuitBreakerOpenException(
///     'Vision API quota near limit. Using ML Kit fallback.',
///     apiName: 'google_vision',
///     threshold: 800,
///     current: 850,
///   );
/// }
/// ```
class CircuitBreakerOpenException extends QuotaException {
  final int threshold;
  final int current;

  const CircuitBreakerOpenException(
    super.message, {
    required this.threshold,
    required this.current,
    super.apiName,
  });

  @override
  String toString() =>
      'CircuitBreakerOpenException: $message (threshold: $threshold, current: $current)';
}

/// Quota Type Enumeration
///
/// Defines different types of quota limits.
enum QuotaType {
  /// Daily quota (resets every 24 hours)
  daily,

  /// Monthly quota (resets every month)
  monthly,

  /// Per-minute rate limit
  perMinute,

  /// Per-second rate limit
  perSecond,
}
