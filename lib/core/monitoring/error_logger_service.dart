import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crashlytics_service.dart';
import 'analytics_service.dart';
import '../shared/exceptions/app_exception.dart';

/// Error logger service provider
/// Story 0.7: Crash Reporting and Performance Monitoring
///
/// Unified error logging that integrates:
/// - Crashlytics (error reporting)
/// - Analytics (error event tracking)
/// - Console logging (debug mode)
final errorLoggerProvider = Provider<ErrorLoggerService>((ref) {
  return ErrorLoggerService(
    crashlytics: ref.watch(crashlyticsServiceProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

/// Unified error logging service
///
/// Provides:
/// - Structured error logging to multiple backends
/// - Error categorization and tagging
/// - Debug vs production logging strategies
/// - Integration with AppException hierarchy
class ErrorLoggerService {
  final CrashlyticsService crashlytics;
  final AnalyticsService analytics;

  ErrorLoggerService({required this.crashlytics, required this.analytics});

  /// Log an error with full context
  ///
  /// This is the primary method for error logging. It:
  /// - Logs to Crashlytics with stack trace
  /// - Logs to Analytics for error metrics
  /// - Logs to console in debug mode
  /// - Handles AppException types specially
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await fetchProducts();
  /// } catch (e, st) {
  ///   await errorLogger.logError(
  ///     e,
  ///     st,
  ///     context: {'operation': 'fetch_products', 'user_id': userId},
  ///     fatal: false,
  ///   );
  /// }
  /// ```
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, dynamic>? context,
    bool fatal = false,
  }) async {
    // Extract error details
    final errorType = error.runtimeType.toString();
    final errorMessage = error.toString();

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ ERROR: $errorType');
      debugPrint('Message: $errorMessage');
      if (context != null && context.isNotEmpty) {
        debugPrint('Context: $context');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace:\n$stackTrace');
      }
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    // Add error type and fatal flag to context
    final enrichedContext = {
      if (context != null) ...context,
      'error_type': errorType,
      'fatal': fatal.toString(),
    };

    // Log to Crashlytics
    await crashlytics.recordError(
      error,
      stackTrace,
      reason: _extractReason(error),
      fatal: fatal,
      information: [
        for (final entry in enrichedContext.entries)
          '${entry.key}: ${entry.value}',
      ],
    );

    // Log to Analytics (for error metrics/dashboards)
    await analytics.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'fatal': fatal,
        'error_category': _categorizeError(error),
        if (error is AppException && error.code != null)
          'error_code': error.code!,
      },
    );

    // Add breadcrumb for context in future errors
    crashlytics.logBreadcrumb('Error: $errorType - ${_extractReason(error)}');
  }

  /// Log a network error (convenience wrapper)
  ///
  /// Automatically categorizes as network error and adds network context
  Future<void> logNetworkError(
    dynamic error,
    StackTrace? stackTrace, {
    String? endpoint,
    int? statusCode,
    String? method,
  }) async {
    await logError(
      error,
      stackTrace,
      context: {
        'category': 'network',
        ...?(endpoint != null ? {'endpoint': endpoint} : null),
        ...?(statusCode != null ? {'status_code': statusCode} : null),
        ...?(method != null ? {'http_method': method} : null),
      },
    );
  }

  /// Log a storage error (convenience wrapper)
  ///
  /// Automatically categorizes as storage error and adds storage context
  Future<void> logStorageError(
    dynamic error,
    StackTrace? stackTrace, {
    String? operation,
    String? storageType, // 'hive', 'firestore', 'secure_storage'
  }) async {
    await logError(
      error,
      stackTrace,
      context: {
        'category': 'storage',
        ...?(operation != null ? {'operation': operation} : null),
        ...?(storageType != null ? {'storage_type': storageType} : null),
      },
    );
  }

  /// Log a validation error (convenience wrapper)
  ///
  /// Automatically categorizes as validation error
  /// Use for user input validation failures
  Future<void> logValidationError(
    dynamic error,
    StackTrace? stackTrace, {
    Map<String, String>? fieldErrors,
  }) async {
    await logError(
      error,
      stackTrace,
      context: {
        'category': 'validation',
        ...?(fieldErrors != null && fieldErrors.isNotEmpty
            ? {'failed_fields': fieldErrors.keys.join(', ')}
            : null),
      },
      fatal: false, // Validation errors are never fatal
    );
  }

  /// Log a sync error (convenience wrapper)
  ///
  /// Automatically categorizes as sync error and adds sync context
  Future<void> logSyncError(
    dynamic error,
    StackTrace? stackTrace, {
    String? phase, // 'upload', 'download', 'conflict_resolution'
    int? itemCount,
  }) async {
    await logError(
      error,
      stackTrace,
      context: {
        'category': 'sync',
        ...?(phase != null ? {'sync_phase': phase} : null),
        ...?(itemCount != null ? {'item_count': itemCount} : null),
      },
    );
  }

  /// Log an OCR error (convenience wrapper)
  ///
  /// Automatically categorizes as OCR error and adds OCR context
  Future<void> logOCRError(
    dynamic error,
    StackTrace? stackTrace, {
    String? engine, // 'google_vision', 'ml_kit'
    int? imageSizeKb,
  }) async {
    await logError(
      error,
      stackTrace,
      context: {
        'category': 'ocr',
        ...?(engine != null ? {'ocr_engine': engine} : null),
        ...?(imageSizeKb != null ? {'image_size_kb': imageSizeKb} : null),
      },
    );
  }

  /// Log a warning (non-fatal issue)
  ///
  /// Use for recoverable errors, fallback scenarios, or unusual states
  ///
  /// Example:
  /// ```dart
  /// if (cache.isEmpty) {
  ///   await errorLogger.logWarning(
  ///     'Cache miss - falling back to network',
  ///     context: {'cache_key': key},
  ///   );
  /// }
  /// ```
  Future<void> logWarning(
    String message, {
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (context != null) {
        debugPrint('Context: $context');
      }
    }

    crashlytics.logBreadcrumb('Warning: $message');

    // Log to analytics for warning metrics
    await analytics.logEvent(
      name: 'warning_logged',
      parameters: {
        'message': message,
        if (context != null)
          ...context.map((k, v) => MapEntry(k, v.toString())),
      },
    );
  }

  /// Log an info breadcrumb for debugging context
  ///
  /// These appear in crash reports to help understand the sequence
  /// of events leading to a crash.
  ///
  /// Example:
  /// ```dart
  /// await errorLogger.logInfo('User opened OCR scanner');
  /// await errorLogger.logInfo('Starting image compression');
  /// ```
  Future<void> logInfo(String message) async {
    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $message');
    }

    crashlytics.logBreadcrumb(message);
  }

  // ========================================================================
  // PRIVATE HELPERS
  // ========================================================================

  /// Extract a concise reason string from an error
  String _extractReason(dynamic error) {
    if (error is AppException) {
      return error.code ?? error.runtimeType.toString();
    }
    return error.runtimeType.toString();
  }

  /// Categorize error for analytics grouping
  String _categorizeError(dynamic error) {
    if (error is NetworkException) return 'network';
    if (error is APIException) return 'api';
    if (error is StorageException) return 'storage';
    if (error is ValidationException) return 'validation';
    if (error is AuthException) return 'auth';
    if (error is SyncException) return 'sync';
    if (error is OCRException) return 'ocr';
    if (error is FeatureUnavailableException) return 'feature_unavailable';
    return 'unknown';
  }
}
