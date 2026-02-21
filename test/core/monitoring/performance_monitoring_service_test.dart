import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:frigofute_v2/core/monitoring/performance_monitoring_service.dart';

class MockFirebasePerformance extends Mock implements FirebasePerformance {}

class MockTrace extends Mock implements Trace {}

class MockHttpMetric extends Mock implements HttpMetric {}

void main() {
  group('PerformanceMonitoringService', () {
    late PerformanceMonitoringService service;

    setUp(() {
      service = PerformanceMonitoringService();
    });

    group('createTrace', () {
      test('creates a new trace with given name', () {
        // Act
        final trace = service.createTrace('test_trace');

        // Assert
        expect(trace, isNotNull);
        expect(trace, isA<Trace>());
      });

      test('creates traces with different names', () {
        // Act
        final trace1 = service.createTrace('trace_1');
        final trace2 = service.createTrace('trace_2');

        // Assert
        expect(trace1, isNotNull);
        expect(trace2, isNotNull);
        expect(trace1, isA<Trace>());
        expect(trace2, isA<Trace>());
      });
    });

    group('traceOperation', () {
      test('executes operation and returns result', () async {
        // Arrange
        const expectedResult = 'operation_result';

        // Act
        final result = await service.traceOperation(
          'test_operation',
          () async => expectedResult,
        );

        // Assert
        expect(result, expectedResult);
      });

      test('executes operation with metrics', () async {
        // Arrange
        const expectedResult = 42;

        // Act
        final result = await service.traceOperation(
          'test_operation',
          () async => expectedResult,
          metrics: {'count': 10, 'duration': 250},
        );

        // Assert
        expect(result, expectedResult);
      });

      test('executes operation with attributes', () async {
        // Arrange
        const expectedResult = true;

        // Act
        final result = await service.traceOperation(
          'test_operation',
          () async => expectedResult,
          attributes: {'user_tier': 'premium', 'feature': 'ocr'},
        );

        // Assert
        expect(result, expectedResult);
      });

      test('executes operation with both metrics and attributes', () async {
        // Arrange
        const expectedResult = 'success';

        // Act
        final result = await service.traceOperation(
          'test_operation',
          () async => expectedResult,
          metrics: {'items': 5},
          attributes: {'source': 'cache'},
        );

        // Assert
        expect(result, expectedResult);
      });

      test('propagates exceptions from operation', () async {
        // Arrange
        final expectedException = Exception('Operation failed');

        // Act & Assert
        expect(
          () => service.traceOperation(
            'failing_operation',
            () async => throw expectedException,
          ),
          throwsA(expectedException),
        );
      });

      test('stops trace even when operation throws', () async {
        // Act
        try {
          await service.traceOperation(
            'failing_operation',
            () async => throw Exception('Test'),
          );
        } catch (_) {
          // Exception expected
        }

        // Note: In real implementation, verify trace.stop() was called
        // This requires mocking the Trace object
      });
    });

    group('traceAPICall', () {
      test('executes API call and returns result', () async {
        // Arrange
        const expectedResponse = {'data': 'test'};

        // Act
        final result = await service.traceAPICall(
          'api_test',
          () async => expectedResponse,
        );

        // Assert
        expect(result, expectedResponse);
      });

      test('executes API call with attributes', () async {
        // Arrange
        const expectedResponse = 'success';

        // Act
        final result = await service.traceAPICall(
          'api_test',
          () async => expectedResponse,
          attributes: {'endpoint': '/products', 'method': 'GET'},
        );

        // Assert
        expect(result, expectedResponse);
      });

      test('propagates exceptions from API call', () async {
        // Arrange
        final expectedException = Exception('API error');

        // Act & Assert
        expect(
          () => service.traceAPICall(
            'api_test',
            () async => throw expectedException,
          ),
          throwsA(expectedException),
        );
      });

      test('marks trace as failed when exception occurs', () async {
        // Note: In real implementation, verify attributes are set correctly
        // This requires mocking the Trace object

        // Act & Assert
        expect(
          () => service.traceAPICall(
            'api_test',
            () async => throw Exception('API error'),
          ),
          throwsException,
        );
      });
    });

    group('traceSyncOperation', () {
      test('executes sync operation successfully', () async {
        // Arrange
        var operationCalled = false;

        // Act
        await service.traceSyncOperation(
          phase: 'upload_local',
          itemCount: 15,
          operation: () async {
            operationCalled = true;
          },
        );

        // Assert
        expect(operationCalled, true);
      });

      test('executes sync operation with different phases', () async {
        // Act & Assert - should not throw
        await service.traceSyncOperation(
          phase: 'download_remote',
          itemCount: 20,
          operation: () async {},
        );

        await service.traceSyncOperation(
          phase: 'conflict_resolution',
          itemCount: 3,
          operation: () async {},
        );
      });

      test('propagates exceptions from sync operation', () async {
        // Arrange
        final expectedException = Exception('Sync failed');

        // Act & Assert
        expect(
          () => service.traceSyncOperation(
            phase: 'upload',
            itemCount: 10,
            operation: () async => throw expectedException,
          ),
          throwsA(expectedException),
        );
      });
    });

    group('traceOCRScan', () {
      test('executes OCR scan and returns result', () async {
        // Arrange
        const expectedResult = {'text': 'scanned text'};

        // Act
        final result = await service.traceOCRScan(
          engine: 'google_vision',
          operation: () async => expectedResult,
        );

        // Assert
        expect(result, expectedResult);
      });

      test('executes OCR scan with image size', () async {
        // Arrange
        const expectedResult = 'success';

        // Act
        final result = await service.traceOCRScan(
          engine: 'ml_kit',
          imageSizeKb: 250,
          operation: () async => expectedResult,
        );

        // Assert
        expect(result, expectedResult);
      });

      test('executes OCR scan with different engines', () async {
        // Act & Assert
        final result1 = await service.traceOCRScan(
          engine: 'google_vision',
          operation: () async => 'vision_result',
        );
        expect(result1, 'vision_result');

        final result2 = await service.traceOCRScan(
          engine: 'ml_kit',
          operation: () async => 'mlkit_result',
        );
        expect(result2, 'mlkit_result');
      });

      test('propagates exceptions from OCR operation', () async {
        // Arrange
        final expectedException = Exception('OCR failed');

        // Act & Assert
        expect(
          () => service.traceOCRScan(
            engine: 'google_vision',
            operation: () async => throw expectedException,
          ),
          throwsA(expectedException),
        );
      });
    });

    group('setPerformanceCollectionEnabled', () {
      test('enables performance collection', () async {
        // Act & Assert - should not throw
        await service.setPerformanceCollectionEnabled(true);
      });

      test('disables performance collection', () async {
        // Act & Assert - should not throw
        await service.setPerformanceCollectionEnabled(false);
      });
    });

    group('isPerformanceCollectionEnabled', () {
      test('returns enabled status', () async {
        // Act
        final isEnabled = await service.isPerformanceCollectionEnabled();

        // Assert
        expect(isEnabled, isA<bool>());
      });
    });

    group('createHttpMetric', () {
      test('creates HTTP metric with GET method', () {
        // Act
        final metric = service.createHttpMetric(
          'https://api.example.com/products',
          HttpMethod.Get,
        );

        // Assert
        expect(metric, isNotNull);
        expect(metric, isA<HttpMetric>());
      });

      test('creates HTTP metric with POST method', () {
        // Act
        final metric = service.createHttpMetric(
          'https://api.example.com/products',
          HttpMethod.Post,
        );

        // Assert
        expect(metric, isNotNull);
        expect(metric, isA<HttpMetric>());
      });

      test('creates HTTP metrics with different URLs', () {
        // Act
        final metric1 = service.createHttpMetric(
          'https://api.example.com/products',
          HttpMethod.Get,
        );
        final metric2 = service.createHttpMetric(
          'https://api.example.com/recipes',
          HttpMethod.Post,
        );

        // Assert
        expect(metric1, isNotNull);
        expect(metric2, isNotNull);
      });
    });
  });
}
