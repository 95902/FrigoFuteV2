import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/api/gemini_throttler.dart';

void main() {
  group('GeminiThrottler', () {
    late GeminiThrottler throttler;

    setUp(() {
      throttler = GeminiThrottler();
    });

    group('throttle()', () {
      test('should allow first request immediately', () async {
        final startTime = DateTime.now();
        await throttler.throttle();
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        expect(elapsed.inMilliseconds, lessThan(100)); // < 100ms (immediate)
      });

      test('should enforce 2-second delay between consecutive requests',
          () async {
        // First request (immediate)
        await throttler.throttle();

        // Second request (should wait ~2 seconds)
        final startTime = DateTime.now();
        await throttler.throttle();
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        expect(
            elapsed.inMilliseconds, greaterThanOrEqualTo(1900)); // ~2 seconds
        expect(elapsed.inMilliseconds, lessThan(2200)); // Tolerance
      });

      test('should allow request after 2-second interval has passed', () async {
        // First request
        await throttler.throttle();

        // Wait 2 seconds manually
        await Future.delayed(const Duration(seconds: 2));

        // Second request (should be immediate since 2s passed)
        final startTime = DateTime.now();
        await throttler.throttle();
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        expect(elapsed.inMilliseconds, lessThan(100)); // Immediate
      });

      test('should handle multiple rapid requests correctly', () async {
        final requestTimes = <DateTime>[];

        for (int i = 0; i < 3; i++) {
          await throttler.throttle();
          requestTimes.add(DateTime.now());
        }

        // Check intervals between requests
        final interval1 = requestTimes[1].difference(requestTimes[0]);
        final interval2 = requestTimes[2].difference(requestTimes[1]);

        expect(interval1.inMilliseconds,
            greaterThanOrEqualTo(1900)); // ~2 seconds
        expect(interval2.inMilliseconds,
            greaterThanOrEqualTo(1900)); // ~2 seconds
      });
    });

    group('reset()', () {
      test('should reset throttler state', () async {
        // Make first request
        await throttler.throttle();

        // Reset
        throttler.reset();

        // Next request should be immediate
        final startTime = DateTime.now();
        await throttler.throttle();
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        expect(elapsed.inMilliseconds, lessThan(100)); // Immediate
      });

      test('should allow multiple resets', () async {
        await throttler.throttle();
        throttler.reset();

        await throttler.throttle();
        throttler.reset();

        final startTime = DateTime.now();
        await throttler.throttle();
        final endTime = DateTime.now();

        final elapsed = endTime.difference(startTime);
        expect(elapsed.inMilliseconds, lessThan(100)); // Immediate
      });
    });

    group('canMakeRequestNow()', () {
      test('should return true before first request', () {
        expect(throttler.canMakeRequestNow(), isTrue);
      });

      test('should return false immediately after request', () async {
        await throttler.throttle();
        expect(throttler.canMakeRequestNow(), isFalse);
      });

      test('should return true after 2-second interval', () async {
        await throttler.throttle();
        expect(throttler.canMakeRequestNow(), isFalse);

        // Wait 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        expect(throttler.canMakeRequestNow(), isTrue);
      });

      test('should return true after reset', () async {
        await throttler.throttle();
        expect(throttler.canMakeRequestNow(), isFalse);

        throttler.reset();
        expect(throttler.canMakeRequestNow(), isTrue);
      });
    });

    group('getRemainingDelay()', () {
      test('should return zero before first request', () {
        expect(throttler.getRemainingDelay(), equals(Duration.zero));
      });

      test('should return ~2 seconds immediately after request', () async {
        await throttler.throttle();
        final remaining = throttler.getRemainingDelay();

        expect(remaining.inMilliseconds, greaterThan(1900));
        expect(remaining.inMilliseconds, lessThanOrEqualTo(2000));
      });

      test('should decrease over time', () async {
        await throttler.throttle();

        final remaining1 = throttler.getRemainingDelay();
        await Future.delayed(const Duration(milliseconds: 500));
        final remaining2 = throttler.getRemainingDelay();

        expect(remaining2.inMilliseconds, lessThan(remaining1.inMilliseconds));
      });

      test('should return zero after 2-second interval', () async {
        await throttler.throttle();

        // Wait 2 seconds
        await Future.delayed(const Duration(seconds: 2));

        expect(throttler.getRemainingDelay(), equals(Duration.zero));
      });

      test('should return zero after reset', () async {
        await throttler.throttle();
        throttler.reset();

        expect(throttler.getRemainingDelay(), equals(Duration.zero));
      });
    });

    group('Edge Cases', () {
      test('should handle very rapid successive calls', () async {
        final startTime = DateTime.now();

        // Make 5 sequential throttled calls
        for (int i = 0; i < 5; i++) {
          await throttler.throttle();
        }

        final endTime = DateTime.now();

        // Should take ~8 seconds (4 * 2s intervals)
        final elapsed = endTime.difference(startTime);
        expect(elapsed.inSeconds, greaterThanOrEqualTo(7));
        expect(elapsed.inSeconds, lessThan(10));
      });

      test('should maintain state across multiple throttle() calls', () async {
        await throttler.throttle();
        expect(throttler.canMakeRequestNow(), isFalse);

        // Wait 1 second (halfway)
        await Future.delayed(const Duration(seconds: 1));
        expect(throttler.canMakeRequestNow(), isFalse);

        // Wait another 1 second (complete)
        await Future.delayed(const Duration(seconds: 1));
        expect(throttler.canMakeRequestNow(), isTrue);
      });
    });

    group('Integration', () {
      test('should work correctly in realistic API call scenario', () async {
        final throttler = GeminiThrottler();
        final callTimes = <DateTime>[];

        // Simulate 3 API calls with throttling
        for (int i = 0; i < 3; i++) {
          await throttler.throttle();
          callTimes.add(DateTime.now());
          // Simulate API call (50ms)
          await Future.delayed(const Duration(milliseconds: 50));
        }

        // Verify intervals are ~2 seconds apart
        expect(callTimes.length, equals(3));
        expect(
          callTimes[1].difference(callTimes[0]).inMilliseconds,
          greaterThanOrEqualTo(1900),
        );
        expect(
          callTimes[2].difference(callTimes[1]).inMilliseconds,
          greaterThanOrEqualTo(1900),
        );
      });
    });
  });
}
