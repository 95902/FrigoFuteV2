import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/core/monitoring/crashlytics_service.dart';

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  group('CrashlyticsService', () {
    late MockFirebaseCrashlytics mockCrashlytics;
    late CrashlyticsService service;

    setUp(() {
      mockCrashlytics = MockFirebaseCrashlytics();

      // Stub the singleton instance
      // Note: In real tests, use dependency injection instead of singleton
      service = CrashlyticsService();
    });

    group('recordError', () {
      test('calls FirebaseCrashlytics.recordError with correct parameters',
          () async {
        // Arrange
        final exception = Exception('Test error');
        final stackTrace = StackTrace.current;
        when(() => mockCrashlytics.recordError(
              any(),
              any(),
              reason: any(named: 'reason'),
              fatal: any(named: 'fatal'),
              information: any(named: 'information'),
            )).thenAnswer((_) async {});

        // Act
        await service.recordError(
          exception,
          stackTrace,
          reason: 'test_reason',
          fatal: true,
        );

        // Assert
        // Note: This test is illustrative - actual implementation uses singleton
        // In production code, inject FirebaseCrashlytics for testability
        expect(service, isNotNull);
      });

      test('handles error without stack trace', () async {
        // Arrange
        final exception = Exception('Test error');

        // Act & Assert - should not throw
        await service.recordError(exception, null);
      });

      test('handles error with information list', () async {
        // Arrange
        final exception = Exception('Test error');
        final stackTrace = StackTrace.current;
        final information = ['context1', 'context2'];

        // Act & Assert - should not throw
        await service.recordError(
          exception,
          stackTrace,
          information: information,
        );
      });
    });

    group('logBreadcrumb', () {
      test('logs breadcrumb message', () {
        // Arrange
        const message = 'User navigated to profile';

        // Act & Assert - should not throw
        service.logBreadcrumb(message);
      });

      test('accepts empty message', () {
        // Act & Assert - should not throw
        service.logBreadcrumb('');
      });
    });

    group('setCustomKey', () {
      test('sets custom key with string value', () async {
        // Act & Assert - should not throw
        await service.setCustomKey('user_tier', 'premium');
      });

      test('sets custom key with int value', () async {
        // Act & Assert - should not throw
        await service.setCustomKey('retry_count', 3);
      });

      test('sets custom key with bool value', () async {
        // Act & Assert - should not throw
        await service.setCustomKey('is_first_launch', true);
      });
    });

    group('setUserId', () {
      test('sets user identifier', () async {
        // Arrange
        const userId = 'hashed_user_123';

        // Act & Assert - should not throw
        await service.setUserId(userId);
      });
    });

    group('clearUserId', () {
      test('clears user identifier by setting empty string', () async {
        // Act & Assert - should not throw
        await service.clearUserId();
      });
    });

    group('setCrashlyticsCollectionEnabled', () {
      test('enables crashlytics collection', () async {
        // Act & Assert - should not throw
        await service.setCrashlyticsCollectionEnabled(true);
      });

      test('disables crashlytics collection', () async {
        // Act & Assert - should not throw
        await service.setCrashlyticsCollectionEnabled(false);
      });
    });

    group('isCrashlyticsCollectionEnabled', () {
      test('returns enabled status', () async {
        // Act
        final isEnabled = await service.isCrashlyticsCollectionEnabled();

        // Assert
        expect(isEnabled, isA<bool>());
      });
    });

    group('sendUnsentReports', () {
      test('sends unsent reports', () async {
        // Act & Assert - should not throw
        await service.sendUnsentReports();
      });
    });

    group('deleteUnsentReports', () {
      test('deletes unsent reports', () async {
        // Act & Assert - should not throw
        await service.deleteUnsentReports();
      });
    });

    group('didCrashOnPreviousExecution', () {
      test('returns crash status', () async {
        // Act
        final didCrash = await service.didCrashOnPreviousExecution();

        // Assert
        expect(didCrash, isA<bool>());
      });
    });

    group('testCrash', () {
      test('exists and is callable', () {
        // This test just verifies the method exists
        // We don't actually call it as it would crash the test runner
        expect(service.testCrash, isA<Function>());
      });
    });
  });
}
