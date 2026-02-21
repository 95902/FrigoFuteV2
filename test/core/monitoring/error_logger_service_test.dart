import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/core/monitoring/error_logger_service.dart';
import 'package:frigofute_v2/core/monitoring/crashlytics_service.dart';
import 'package:frigofute_v2/core/monitoring/analytics_service.dart';
import 'package:frigofute_v2/core/shared/exceptions/app_exception.dart';

class MockCrashlyticsService extends Mock implements CrashlyticsService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(StackTrace.empty);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(<Object>[]);
  });

  group('ErrorLoggerService', () {
    late MockCrashlyticsService mockCrashlytics;
    late MockAnalyticsService mockAnalytics;
    late ErrorLoggerService service;

    setUp(() {
      mockCrashlytics = MockCrashlyticsService();
      mockAnalytics = MockAnalyticsService();
      service = ErrorLoggerService(
        crashlytics: mockCrashlytics,
        analytics: mockAnalytics,
      );

      // Setup default stubs
      when(() => mockCrashlytics.recordError(
            any(),
            any(),
            reason: any(named: 'reason'),
            fatal: any(named: 'fatal'),
            information: any(named: 'information'),
          )).thenAnswer((_) async {});

      when(() => mockCrashlytics.logBreadcrumb(any())).thenReturn(null);

      when(() => mockAnalytics.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          )).thenAnswer((_) async {});
    });

    group('logError', () {
      test('logs error to Crashlytics and Analytics', () async {
        // Arrange
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(named: 'parameters'),
            )).called(1);

        verify(() => mockCrashlytics.logBreadcrumb(any())).called(1);
      });

      test('logs error with context', () async {
        // Arrange
        final error = Exception('Test error');
        final stackTrace = StackTrace.current;
        final context = {'operation': 'fetch_products', 'user_id': 'test_123'};

        // Act
        await service.logError(error, stackTrace, context: context);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs fatal error', () async {
        // Arrange
        final error = Exception('Fatal error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logError(error, stackTrace, fatal: true);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: true,
              information: any(named: 'information'),
            )).called(1);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(named: 'parameters', that: contains('fatal')),
            )).called(1);
      });

      test('logs AppException with code', () async {
        // Arrange
        const error = NetworkException('Network error', 'NETWORK_TIMEOUT');
        final stackTrace = StackTrace.current;

        // Act
        await service.logError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: 'NETWORK_TIMEOUT',
              fatal: false,
              information: any(named: 'information'),
            )).called(1);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(
                named: 'parameters',
                that: allOf([
                  contains('error_code'),
                  contains('error_category'),
                ]),
              ),
            )).called(1);
      });

      test('categorizes different exception types correctly', () async {
        // Test NetworkException
        const networkError = NetworkException('Network error');
        await service.logError(networkError, StackTrace.current);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(
                named: 'parameters',
                that: predicate<Map<String, Object?>>((params) =>
                    params['error_category'] == 'network'),
              ),
            )).called(1);

        // Test APIException
        const apiError = APIException('API error', 'API_ERROR', 500);
        await service.logError(apiError, StackTrace.current);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(
                named: 'parameters',
                that: predicate<Map<String, Object?>>((params) =>
                    params['error_category'] == 'api'),
              ),
            )).called(1);

        // Test ValidationException
        const validationError = ValidationException('Validation error');
        await service.logError(validationError, StackTrace.current);

        verify(() => mockAnalytics.logEvent(
              name: 'error_occurred',
              parameters: any(
                named: 'parameters',
                that: predicate<Map<String, Object?>>((params) =>
                    params['error_category'] == 'validation'),
              ),
            )).called(1);
      });
    });

    group('logNetworkError', () {
      test('logs network error with all parameters', () async {
        // Arrange
        final error = Exception('Network timeout');
        final stackTrace = StackTrace.current;

        // Act
        await service.logNetworkError(
          error,
          stackTrace,
          endpoint: '/api/products',
          statusCode: 500,
          method: 'GET',
        );

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs network error without optional parameters', () async {
        // Arrange
        final error = Exception('Network error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logNetworkError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });
    });

    group('logStorageError', () {
      test('logs storage error with all parameters', () async {
        // Arrange
        final error = Exception('Storage write failed');
        final stackTrace = StackTrace.current;

        // Act
        await service.logStorageError(
          error,
          stackTrace,
          operation: 'write',
          storageType: 'hive',
        );

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs storage error without optional parameters', () async {
        // Arrange
        final error = Exception('Storage error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logStorageError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });
    });

    group('logValidationError', () {
      test('logs validation error with field errors', () async {
        // Arrange
        const error = ValidationException(
          'Validation failed',
          {'email': 'Invalid email', 'password': 'Too short'},
        );
        final stackTrace = StackTrace.current;

        // Act
        await service.logValidationError(
          error,
          stackTrace,
          fieldErrors: {'email': 'Invalid email', 'password': 'Too short'},
        );

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs validation error as non-fatal', () async {
        // Arrange
        const error = ValidationException('Validation failed');
        final stackTrace = StackTrace.current;

        // Act
        await service.logValidationError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false, // Always non-fatal
              information: any(named: 'information'),
            )).called(1);
      });
    });

    group('logSyncError', () {
      test('logs sync error with all parameters', () async {
        // Arrange
        final error = Exception('Sync failed');
        final stackTrace = StackTrace.current;

        // Act
        await service.logSyncError(
          error,
          stackTrace,
          phase: 'upload',
          itemCount: 15,
        );

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs sync error without optional parameters', () async {
        // Arrange
        final error = Exception('Sync error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logSyncError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });
    });

    group('logOCRError', () {
      test('logs OCR error with all parameters', () async {
        // Arrange
        final error = Exception('OCR scan failed');
        final stackTrace = StackTrace.current;

        // Act
        await service.logOCRError(
          error,
          stackTrace,
          engine: 'google_vision',
          imageSizeKb: 250,
        );

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });

      test('logs OCR error without optional parameters', () async {
        // Arrange
        final error = Exception('OCR error');
        final stackTrace = StackTrace.current;

        // Act
        await service.logOCRError(error, stackTrace);

        // Assert
        verify(() => mockCrashlytics.recordError(
              error,
              stackTrace,
              reason: any(named: 'reason'),
              fatal: false,
              information: any(named: 'information'),
            )).called(1);
      });
    });

    group('logWarning', () {
      test('logs warning to Analytics and breadcrumb', () async {
        // Arrange
        const message = 'Cache miss - falling back to network';

        // Act
        await service.logWarning(message);

        // Assert
        verify(() => mockCrashlytics.logBreadcrumb('Warning: $message'))
            .called(1);

        verify(() => mockAnalytics.logEvent(
              name: 'warning_logged',
              parameters: any(named: 'parameters'),
            )).called(1);
      });

      test('logs warning with context', () async {
        // Arrange
        const message = 'Unusual state detected';
        final context = {'cache_key': 'products', 'retry_count': 3};

        // Act
        await service.logWarning(message, context: context);

        // Assert
        verify(() => mockCrashlytics.logBreadcrumb('Warning: $message'))
            .called(1);

        verify(() => mockAnalytics.logEvent(
              name: 'warning_logged',
              parameters: any(
                named: 'parameters',
                that: allOf([
                  contains('message'),
                  contains('cache_key'),
                  contains('retry_count'),
                ]),
              ),
            )).called(1);
      });
    });

    group('logInfo', () {
      test('logs info breadcrumb', () async {
        // Arrange
        const message = 'User opened OCR scanner';

        // Act
        await service.logInfo(message);

        // Assert
        verify(() => mockCrashlytics.logBreadcrumb(message)).called(1);
      });

      test('logs multiple breadcrumbs in sequence', () async {
        // Act
        await service.logInfo('User opened OCR scanner');
        await service.logInfo('Image selected');
        await service.logInfo('Starting compression');

        // Assert
        verify(() => mockCrashlytics.logBreadcrumb('User opened OCR scanner'))
            .called(1);
        verify(() => mockCrashlytics.logBreadcrumb('Image selected')).called(1);
        verify(() => mockCrashlytics.logBreadcrumb('Starting compression'))
            .called(1);
      });
    });
  });
}
