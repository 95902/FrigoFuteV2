import 'dart:math';

/// Sync retry manager with exponential backoff
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Manages retry logic for failed sync operations.
/// Uses exponential backoff strategy: 1s → 2s → 4s → 8s (max).
/// Maximum 3 retry attempts before moving to dead-letter queue.
///
/// Example:
/// ```dart
/// final manager = SyncRetryManager();
/// final delay = manager.calculateBackoff(2); // 4 seconds
/// await Future.delayed(delay);
/// ```
class SyncRetryManager {
  /// Maximum number of retry attempts before giving up
  static const int maxRetries = 3;

  /// Base delay in seconds for first retry
  static const int baseDelaySeconds = 1;

  /// Maximum delay in seconds (cap for exponential backoff)
  static const int maxDelaySeconds = 8;

  /// Calculates exponential backoff delay for retry attempt
  ///
  /// Formula: delay = min(baseDelay * 2^retryCount, maxDelay)
  ///
  /// Examples:
  /// - Retry 0: 1s
  /// - Retry 1: 2s
  /// - Retry 2: 4s
  /// - Retry 3: 8s
  /// - Retry 4+: 8s (capped)
  Duration calculateBackoff(int retryCount) {
    final delaySeconds = min(
      baseDelaySeconds * pow(2, retryCount).toInt(),
      maxDelaySeconds,
    );
    return Duration(seconds: delaySeconds);
  }

  /// Checks if item should be retried based on retry count
  ///
  /// Returns true if retryCount < maxRetries.
  bool shouldRetry(int retryCount) {
    return retryCount < maxRetries;
  }

  /// Executes an async operation with retry logic
  ///
  /// Retries up to [maxAttempts] times with exponential backoff.
  /// Returns the result if successful, or throws after max retries.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final result = await manager.executeWithRetry(
  ///     operation: () => syncToFirestore(item),
  ///   );
  /// } catch (e) {
  ///   // Max retries exceeded, move to dead-letter queue
  /// }
  /// ```
  Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = maxRetries,
    void Function(int attempt, dynamic error)? onRetry,
  }) async {
    int attempt = 0;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxAttempts) {
          rethrow; // Max retries exceeded
        }

        // Calculate backoff delay
        final delay = calculateBackoff(attempt - 1);

        // Notify callback if provided
        onRetry?.call(attempt, e);

        // Wait before retrying
        await Future.delayed(delay);
      }
    }
  }

  /// Calculate total time spent on retries (for metrics)
  ///
  /// Returns the sum of all backoff delays for given retry count.
  Duration calculateTotalRetryTime(int retryCount) {
    int totalSeconds = 0;
    for (int i = 0; i < retryCount; i++) {
      totalSeconds += min(
        baseDelaySeconds * pow(2, i).toInt(),
        maxDelaySeconds,
      );
    }
    return Duration(seconds: totalSeconds);
  }
}
