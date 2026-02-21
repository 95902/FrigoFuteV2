import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Crashlytics service provider
/// Story 0.7: Crash Reporting and Performance Monitoring
final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  return CrashlyticsService();
});

/// Wrapper for Firebase Crashlytics functionality
///
/// Provides:
/// - Error reporting with context
/// - Breadcrumb logging for debugging
/// - Custom keys for filtering/analysis
/// - User identification (hashed, no PII)
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Record an error with stack trace and context
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await riskyOperation();
  /// } catch (e, st) {
  ///   await crashlytics.recordError(
  ///     e,
  ///     st,
  ///     reason: 'risky_operation_failed',
  ///     fatal: false,
  ///   );
  /// }
  /// ```
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Iterable<Object> information = const [],
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
      information: information,
    );
  }

  /// Log a breadcrumb for debugging context
  ///
  /// Breadcrumbs appear in crash reports to help understand
  /// the sequence of events leading to a crash.
  ///
  /// Example:
  /// ```dart
  /// crashlytics.logBreadcrumb('User opened OCR scanner');
  /// crashlytics.logBreadcrumb('Starting image compression');
  /// ```
  void logBreadcrumb(String message) {
    _crashlytics.log(message);
  }

  /// Set custom key-value for additional context
  ///
  /// These appear in the Crashlytics dashboard and can be
  /// used for filtering and analysis.
  ///
  /// Example:
  /// ```dart
  /// await crashlytics.setCustomKey('user_tier', 'premium');
  /// await crashlytics.setCustomKey('network_type', 'wifi');
  /// ```
  Future<void> setCustomKey(String key, Object value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  /// Set user identifier for crash attribution
  ///
  /// ⚠️ WARNING: Use hashed ID only, no PII (email, phone, etc.)
  ///
  /// Example:
  /// ```dart
  /// final hashedId = userId.hashCode.toString();
  /// await crashlytics.setUserId(hashedId);
  /// ```
  Future<void> setUserId(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  /// Clear user identifier (e.g., on logout)
  Future<void> clearUserId() async {
    await _crashlytics.setUserIdentifier('');
  }

  /// Force a test crash (debug/development only)
  ///
  /// ⚠️ WARNING: This will crash the app!
  /// Use only for testing Crashlytics integration.
  ///
  /// To test:
  /// 1. Call this method
  /// 2. Wait 1-2 minutes
  /// 3. Check Firebase Console → Crashlytics
  void testCrash() {
    _crashlytics.crash();
  }

  /// Enable/disable crash collection
  ///
  /// Set to false during development to avoid polluting
  /// production crash reports.
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  /// Check if crash collection is enabled
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return _crashlytics.isCrashlyticsCollectionEnabled;
  }

  /// Send unhandled crashes (iOS only feature)
  /// This is handled automatically on Android
  Future<void> sendUnsentReports() async {
    await _crashlytics.sendUnsentReports();
  }

  /// Delete unsent reports (useful for privacy compliance)
  Future<void> deleteUnsentReports() async {
    await _crashlytics.deleteUnsentReports();
  }

  /// Check if there are unsent reports
  Future<bool> didCrashOnPreviousExecution() async {
    return _crashlytics.didCrashOnPreviousExecution();
  }
}
