import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/validation/debounced_validator.dart';

/// Unit tests for DebouncedValidator
/// Story 1.1: Create Account with Email and Password
///
/// Tests debounced validation for real-time form validation
void main() {
  group('DebouncedValidator', () {
    late DebouncedValidator validator;

    setUp(() {
      validator = DebouncedValidator();
    });

    tearDown(() {
      validator.dispose();
    });

    test('should delay action execution by default 300ms', () async {
      int executionCount = 0;

      validator.run(() {
        executionCount++;
      });

      // Should not execute immediately
      expect(executionCount, 0);

      // Should execute after delay
      await Future.delayed(const Duration(milliseconds: 350));
      expect(executionCount, 1);
    });

    test('should cancel previous timer when called multiple times', () async {
      int executionCount = 0;

      // Call 5 times rapidly
      for (int i = 0; i < 5; i++) {
        validator.run(() {
          executionCount++;
        });
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Wait for any pending timers
      await Future.delayed(const Duration(milliseconds: 400));

      // Only last call should execute
      expect(executionCount, 1);
    });

    test('should respect custom delay duration', () async {
      int executionCount = 0;

      validator.run(
        () {
          executionCount++;
        },
        delay: const Duration(milliseconds: 100),
      );

      // Should not execute before custom delay
      await Future.delayed(const Duration(milliseconds: 50));
      expect(executionCount, 0);

      // Should execute after custom delay
      await Future.delayed(const Duration(milliseconds: 100));
      expect(executionCount, 1);
    });

    test('should not execute action after dispose', () async {
      int executionCount = 0;

      validator.run(() {
        executionCount++;
      });

      // Dispose before timer completes
      validator.dispose();

      // Wait longer than delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Should not have executed
      expect(executionCount, 0);
    });

    test('should handle multiple dispose calls safely', () {
      expect(() {
        validator.dispose();
        validator.dispose();
        validator.dispose();
      }, returnsNormally);
    });

    test('should allow reuse after dispose', () async {
      validator.dispose();

      int executionCount = 0;
      validator.run(() {
        executionCount++;
      });

      await Future.delayed(const Duration(milliseconds: 350));
      expect(executionCount, 1);
    });
  });
}
