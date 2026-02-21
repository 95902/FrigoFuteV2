/// Base exception for all application errors
/// Story 0.7: Crash Reporting and Performance Monitoring
///
/// This hierarchy enables:
/// - Type-safe error handling
/// - Structured logging to Crashlytics
/// - User-friendly error messages
/// - Error categorization for analytics
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, [this.code, this.originalError]);

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Network-related errors (connection, timeout, DNS)
class NetworkException extends AppException {
  const NetworkException(
    String message, [
    String? code,
    dynamic originalError,
  ]) : super(message, code ?? 'NETWORK_ERROR', originalError);

  @override
  String toString() => 'NetworkException: $message (code: $code)';
}

/// API errors (4xx, 5xx status codes)
class APIException extends AppException {
  final int? statusCode;

  const APIException(
    String message, [
    String? code,
    this.statusCode,
    dynamic originalError,
  ]) : super(message, code ?? 'API_ERROR', originalError);

  @override
  String toString() =>
      'APIException: $message (code: $code, status: $statusCode)';
}

/// API quota exceeded (429 status, rate limiting)
class QuotaExceededException extends APIException {
  const QuotaExceededException(String message)
      : super(message, 'QUOTA_EXCEEDED', 429);

  @override
  String toString() => 'QuotaExceededException: $message';
}

/// Validation errors (form validation, business rules)
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException(String message, [this.fieldErrors])
      : super(message, 'VALIDATION_FAILED');

  @override
  String toString() {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return 'ValidationException: $message (fields: ${fieldErrors!.keys.join(", ")})';
    }
    return 'ValidationException: $message';
  }
}

/// Storage errors (Hive, Firestore, disk operations)
class StorageException extends AppException {
  const StorageException(
    String message, [
    String? code,
    dynamic originalError,
  ]) : super(message, code ?? 'STORAGE_ERROR', originalError);

  @override
  String toString() => 'StorageException: $message (code: $code)';
}

/// Authentication errors (login, logout, token errors)
class AuthException extends AppException {
  const AuthException(
    String message, [
    String? code,
    dynamic originalError,
  ]) : super(message, code ?? 'AUTH_ERROR', originalError);

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Feature not available (free tier, regional restriction, feature flags)
class FeatureUnavailableException extends AppException {
  final bool requiresPremium;

  const FeatureUnavailableException(
    String message, {
    this.requiresPremium = false,
  }) : super(message, 'FEATURE_UNAVAILABLE');

  @override
  String toString() =>
      'FeatureUnavailableException: $message (premium: $requiresPremium)';
}

/// OCR-specific errors (scan failures, API errors)
class OCRException extends APIException {
  final String? apiEngine; // 'google_vision', 'ml_kit'

  const OCRException(
    String message, {
    this.apiEngine,
    int? statusCode,
    dynamic originalError,
  }) : super(message, 'OCR_ERROR', statusCode, originalError);

  @override
  String toString() =>
      'OCRException: $message (engine: $apiEngine, code: $code)';
}

/// Data sync errors (conflict resolution, network sync)
class SyncException extends AppException {
  final SyncPhase? phase;

  const SyncException(
    String message, [
    this.phase,
    dynamic originalError,
  ]) : super(message, 'SYNC_ERROR', originalError);

  @override
  String toString() => 'SyncException: $message (phase: $phase)';
}

/// Sync phases for detailed error reporting
enum SyncPhase {
  uploadLocal,
  downloadRemote,
  conflictResolution,
  syncLocal,
}
