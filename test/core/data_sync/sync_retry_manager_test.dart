import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/data_sync/sync_retry_manager.dart';

/// Unit tests for SyncRetryManager
/// Story 0.9 Phase 9: Testing
///
/// Tests exponential backoff retry logic
void main() {
  group('SyncRetryManager', () {
    late SyncRetryManager manager;

    setUp(() {
      manager = SyncRetryManager();
    });

    group('calculateBackoff()', () {
      test('should calculate exponential backoff correctly', () {
        expect(manager.calculateBackoff(0), const Duration(seconds: 1));
        expect(manager.calculateBackoff(1), const Duration(seconds: 2));
        expect(manager.calculateBackoff(2), const Duration(seconds: 4));
        expect(manager.calculateBackoff(3), const Duration(seconds: 8));
        expect(manager.calculateBackoff(4),
            const Duration(seconds: 8)); // Capped at 8s
        expect(manager.calculateBackoff(10),
            const Duration(seconds: 8)); // Still capped
      });

      test('should handle retry count 0', () {
        final backoff = manager.calculateBackoff(0);
        expect(backoff.inSeconds, 1);
      });

      test('should cap at maxDelaySeconds', () {
        final backoff = manager.calculateBackoff(100);
        expect(backoff.inSeconds, SyncRetryManager.maxDelaySeconds);
      });
    });

    group('shouldRetry()', () {
      test('should allow retry when count < maxRetries', () {
        expect(manager.shouldRetry(0), true);
        expect(manager.shouldRetry(1), true);
        expect(manager.shouldRetry(2), true);
      });

      test('should not allow retry when count >= maxRetries', () {
        expect(manager.shouldRetry(3), false);
        expect(manager.shouldRetry(4), false);
        expect(manager.shouldRetry(100), false);
      });
    });

    group('executeWithRetry()', () {
      test('should succeed on first attempt', () async {
        int attemptCount = 0;

        final result = await manager.executeWithRetry(
          operation: () async {
            attemptCount++;
            return 'success';
          },
        );

        expect(result, 'success');
        expect(attemptCount, 1);
      });

      test('should retry on failure and eventually succeed', () async {
        int attemptCount = 0;

        final result = await manager.executeWithRetry(
          operation: () async {
            attemptCount++;
            if (attemptCount < 2) {
              throw Exception('Temporary failure');
            }
            return 'success';
          },
          maxAttempts: 3,
        );

        expect(result, 'success');
        expect(attemptCount, 2); // Failed once, succeeded on 2nd attempt
      });

      test('should throw after max retries exceeded', () async {
        int attemptCount = 0;

        expect(
          () => manager.executeWithRetry(
            operation: () async {
              attemptCount++;
              throw Exception('Permanent failure');
            },
            maxAttempts: 3,
          ),
          throwsA(isA<Exception>()),
        );

        // Should have attempted maxAttempts times
        await Future.delayed(const Duration(milliseconds: 100));
        expect(attemptCount, 3);
      });

      test('should call onRetry callback on each retry', () async {
        final retryAttempts = <int>[];
        final errors = <dynamic>[];

        try {
          await manager.executeWithRetry(
            operation: () async => throw Exception('Test error'),
            maxAttempts: 3,
            onRetry: (attempt, error) {
              retryAttempts.add(attempt);
              errors.add(error);
            },
          );
        } catch (e) {
          // Expected to throw after max retries
        }

        expect(retryAttempts, [1, 2]);
        expect(errors.length, 2);
      });

      test('should respect custom maxAttempts', () async {
        int attemptCount = 0;

        try {
          await manager.executeWithRetry(
            operation: () async {
              attemptCount++;
              throw Exception('Error');
            },
            maxAttempts: 5,
          );
        } catch (e) {
          // Expected
        }

        await Future.delayed(const Duration(milliseconds: 100));
        expect(attemptCount, 5);
      });
    });

    group('calculateTotalRetryTime()', () {
      test('should calculate total retry time correctly', () {
        // Retry 0: 1s
        // Retry 1: 2s
        // Retry 2: 4s
        // Total: 7s
        final totalTime = manager.calculateTotalRetryTime(3);
        expect(totalTime.inSeconds, 7);
      });

      test('should handle retry count 0', () {
        final totalTime = manager.calculateTotalRetryTime(0);
        expect(totalTime.inSeconds, 0);
      });

      test('should handle retry count 1', () {
        final totalTime = manager.calculateTotalRetryTime(1);
        expect(totalTime.inSeconds, 1);
      });

      test('should respect maxDelaySeconds cap', () {
        // Large retry count should respect cap
        final totalTime = manager.calculateTotalRetryTime(10);

        // Calculate expected: 1 + 2 + 4 + 8 + 8 + 8 + 8 + 8 + 8 + 8 = 63s
        expect(totalTime.inSeconds, 63);
      });
    });
  });
}
