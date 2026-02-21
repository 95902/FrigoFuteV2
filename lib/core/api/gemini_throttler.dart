import 'dart:async';

/// Gemini AI Request Throttler
/// Story 0.10 Phase 7: Rate Limiting & Quota Management
///
/// Implements client-side throttling to prevent excessive API calls.
/// Ensures maximum 1 request per 2 seconds to comply with Gemini API rate limits.
///
/// Usage:
/// ```dart
/// final throttler = GeminiThrottler();
///
/// Future<String> analyzeMeal(String imageBase64) async {
///   await throttler.throttle(); // Wait if needed
///   final result = await geminiRemoteDataSource.analyzeMeal(imageBase64);
///   return result;
/// }
/// ```
class GeminiThrottler {
  /// Minimum interval between consecutive requests (2 seconds)
  static const Duration minRequestInterval = Duration(seconds: 2);

  /// Timestamp of the last request
  DateTime? _lastRequestTime;

  /// Throttles requests to ensure minimum interval between calls.
  ///
  /// If the last request was made less than [minRequestInterval] ago,
  /// this method will wait for the remaining time before returning.
  ///
  /// Returns a [Future] that completes when the request can proceed.
  ///
  /// Example:
  /// ```dart
  /// final throttler = GeminiThrottler();
  /// await throttler.throttle(); // May wait up to 2 seconds
  /// // Now safe to make API call
  /// ```
  Future<void> throttle() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);

      if (elapsed < minRequestInterval) {
        final delay = minRequestInterval - elapsed;
        await Future.delayed(delay);
      }
    }

    _lastRequestTime = DateTime.now();
  }

  /// Resets the throttler state.
  ///
  /// Useful for testing or when you want to clear the throttle state.
  ///
  /// Example:
  /// ```dart
  /// throttler.reset();
  /// await throttler.throttle(); // No delay
  /// ```
  void reset() {
    _lastRequestTime = null;
  }

  /// Checks if a request can be made immediately without waiting.
  ///
  /// Returns `true` if the minimum interval has elapsed since the last request,
  /// or if no request has been made yet.
  ///
  /// Example:
  /// ```dart
  /// if (throttler.canMakeRequestNow()) {
  ///   // Make request immediately
  /// } else {
  ///   // Show loading indicator before throttle wait
  ///   await throttler.throttle();
  /// }
  /// ```
  bool canMakeRequestNow() {
    if (_lastRequestTime == null) return true;

    final elapsed = DateTime.now().difference(_lastRequestTime!);
    return elapsed >= minRequestInterval;
  }

  /// Gets the remaining time until the next request can be made.
  ///
  /// Returns [Duration.zero] if a request can be made immediately.
  ///
  /// Example:
  /// ```dart
  /// final remaining = throttler.getRemainingDelay();
  /// if (remaining > Duration.zero) {
  ///   print('Please wait ${remaining.inSeconds} seconds');
  /// }
  /// ```
  Duration getRemainingDelay() {
    if (_lastRequestTime == null) return Duration.zero;

    final elapsed = DateTime.now().difference(_lastRequestTime!);

    if (elapsed >= minRequestInterval) {
      return Duration.zero;
    }

    return minRequestInterval - elapsed;
  }
}
