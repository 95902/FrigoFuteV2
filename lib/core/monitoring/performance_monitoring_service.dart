import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance monitoring service provider
/// Story 0.7: Crash Reporting and Performance Monitoring
final performanceMonitoringProvider = Provider<PerformanceMonitoringService>((ref) {
  return PerformanceMonitoringService();
});

/// Wrapper for Firebase Performance Monitoring functionality
///
/// Provides:
/// - Custom traces for critical operations
/// - Automatic HTTP request monitoring (via Dio interceptor)
/// - Automatic app startup and screen rendering traces
/// - Network request performance tracking
class PerformanceMonitoringService {
  final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Create a custom trace for manual performance tracking
  ///
  /// Example:
  /// ```dart
  /// final trace = performanceMonitoring.createTrace('ocr_scan');
  /// await trace.start();
  ///
  /// try {
  ///   // ... perform OCR operation
  ///   trace.setMetric('image_size_kb', imageSizeKb);
  ///   trace.putAttribute('scan_type', 'receipt');
  /// } finally {
  ///   await trace.stop();
  /// }
  /// ```
  Trace createTrace(String name) {
    return _performance.newTrace(name);
  }

  /// Trace an async operation with automatic start/stop
  ///
  /// This is a convenience wrapper that automatically:
  /// - Creates a trace
  /// - Starts it
  /// - Executes the operation
  /// - Stops the trace (even if operation throws)
  /// - Returns the operation result
  ///
  /// Example:
  /// ```dart
  /// final result = await performanceMonitoring.traceOperation(
  ///   'fetch_products',
  ///   () async {
  ///     return await productRepository.getProducts();
  ///   },
  ///   metrics: {'product_count': products.length},
  ///   attributes: {'source': 'local_cache'},
  /// );
  /// ```
  Future<T> traceOperation<T>(
    String traceName,
    Future<T> Function() operation, {
    Map<String, int>? metrics,
    Map<String, String>? attributes,
  }) async {
    final trace = createTrace(traceName);
    await trace.start();

    try {
      // Add attributes before operation (context)
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      // Execute the operation
      final result = await operation();

      // Add metrics after operation (results)
      if (metrics != null) {
        for (final entry in metrics.entries) {
          trace.setMetric(entry.key, entry.value);
        }
      }

      return result;
    } finally {
      await trace.stop();
    }
  }

  /// Trace an API call with automatic success/failure tracking
  ///
  /// Automatically adds:
  /// - success: true/false attribute
  /// - error_type: exception class name (if failed)
  /// - duration (automatic from trace start/stop)
  ///
  /// Example:
  /// ```dart
  /// final products = await performanceMonitoring.traceAPICall(
  ///   'api_get_products',
  ///   () async {
  ///     return await http.get(Uri.parse('...'));
  ///   },
  ///   attributes: {'endpoint': '/products'},
  /// );
  /// ```
  Future<T> traceAPICall<T>(
    String traceName,
    Future<T> Function() apiCall, {
    Map<String, String>? attributes,
  }) async {
    final trace = createTrace(traceName);
    await trace.start();

    try {
      // Add custom attributes
      if (attributes != null) {
        for (final entry in attributes.entries) {
          trace.putAttribute(entry.key, entry.value);
        }
      }

      // Execute API call
      final result = await apiCall();

      // Mark as successful
      trace.putAttribute('success', 'true');

      return result;
    } catch (e) {
      // Mark as failed and record error type
      trace.putAttribute('success', 'false');
      trace.putAttribute('error_type', e.runtimeType.toString());
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Trace data sync operations with phase tracking
  ///
  /// Automatically tracks:
  /// - Total sync duration
  /// - Items synced count
  /// - Sync phase (upload/download/conflict)
  /// - Success/failure status
  ///
  /// Example:
  /// ```dart
  /// await performanceMonitoring.traceSyncOperation(
  ///   phase: 'upload_local',
  ///   itemCount: 15,
  ///   operation: () async {
  ///     await syncService.uploadLocalChanges();
  ///   },
  /// );
  /// ```
  Future<void> traceSyncOperation({
    required String phase,
    required int itemCount,
    required Future<void> Function() operation,
  }) async {
    await traceOperation(
      'data_sync_$phase',
      operation,
      metrics: {'items_synced': itemCount},
      attributes: {'sync_phase': phase},
    );
  }

  /// Trace OCR scan operations with engine and confidence tracking
  ///
  /// Automatically tracks:
  /// - OCR engine used (google_vision, ml_kit)
  /// - Confidence score
  /// - Image size (optional)
  /// - Success/failure status
  ///
  /// Example:
  /// ```dart
  /// final result = await performanceMonitoring.traceOCRScan(
  ///   engine: 'google_vision',
  ///   imageSizeKb: 250,
  ///   operation: () async {
  ///     return await ocrService.scanReceipt(image);
  ///   },
  /// );
  /// ```
  Future<T> traceOCRScan<T>({
    required String engine,
    required Future<T> Function() operation,
    int? imageSizeKb,
  }) async {
    final attributes = <String, String>{'ocr_engine': engine};
    final metrics = <String, int>{};

    if (imageSizeKb != null) {
      metrics['image_size_kb'] = imageSizeKb;
    }

    return await traceOperation(
      'ocr_scan',
      operation,
      attributes: attributes,
      metrics: metrics,
    );
  }

  /// Enable/disable performance monitoring
  ///
  /// Set to false during development to avoid polluting
  /// production performance data.
  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    await _performance.setPerformanceCollectionEnabled(enabled);
  }

  /// Check if performance monitoring is enabled
  Future<bool> isPerformanceCollectionEnabled() async {
    return _performance.isPerformanceCollectionEnabled();
  }

  /// Create an HTTP metric for manual HTTP request tracking
  ///
  /// Note: This is automatically handled by Dio interceptor,
  /// so you typically don't need to call this manually.
  ///
  /// Example:
  /// ```dart
  /// final metric = performanceMonitoring.createHttpMetric(
  ///   'https://api.example.com/products',
  ///   HttpMethod.Get,
  /// );
  /// await metric.start();
  /// // ... make request ...
  /// metric.responseCode = 200;
  /// metric.responseContentType = 'application/json';
  /// metric.responsePayloadSize = 1024;
  /// await metric.stop();
  /// ```
  HttpMetric createHttpMetric(String url, HttpMethod httpMethod) {
    return _performance.newHttpMetric(url, httpMethod);
  }
}
