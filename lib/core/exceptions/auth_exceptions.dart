import 'package:firebase_auth/firebase_auth.dart';

/// Authentication exception with user-friendly error messages
/// Story 1.1: Create Account with Email and Password
///
/// Converts Firebase Auth error codes to localized error messages.
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, {this.code = 'unknown'});

  /// Creates AuthException from Firebase Auth exception.
  ///
  /// Maps Firebase error codes to user-friendly messages:
  ///
  /// **Signup errors (Story 1.1)**:
  /// - `email-already-in-use`: Email is already registered
  /// - `invalid-email`: Email format is invalid
  /// - `weak-password`: Password is too weak (< 6 chars)
  ///
  /// **Login errors (Story 1.2)**:
  /// - `user-not-found`: No user exists with this email (generic message for privacy)
  /// - `wrong-password`: Password is incorrect (generic message for privacy)
  /// - `user-disabled`: Account has been disabled by admin
  /// - `too-many-requests`: Too many failed login attempts (rate limiting)
  ///
  /// **Common errors**:
  /// - `network-request-failed`: No internet connection
  /// - `operation-not-allowed`: Authentication method is disabled
  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Signup-specific errors (Story 1.1)
      case 'email-already-in-use':
        return const AuthException(
          "This email is already registered. Use 'Forgot Password?' to recover.",
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          'Password is too weak. Use at least 8 characters.',
          code: 'weak-password',
        );

      // Login-specific errors (Story 1.2)
      // For security, we don't reveal if user exists (prevents user enumeration)
      case 'user-not-found':
        return const AuthException(
          'Incorrect email or password. Please try again.',
          code: 'invalid-credentials',
        );
      case 'wrong-password':
        return const AuthException(
          'Incorrect email or password. Please try again.',
          code: 'invalid-credentials',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );

      // Common errors
      case 'invalid-email':
        return const AuthException(
          'Please enter a valid email address.',
          code: 'invalid-email',
        );
      case 'network-request-failed':
        return const AuthException(
          'Connection failed. Please check your internet and try again.',
          code: 'network-request-failed',
        );
      case 'operation-not-allowed':
        return const AuthException(
          'Email/password authentication is currently disabled.',
          code: 'operation-not-allowed',
        );

      default:
        return AuthException(
          'Something went wrong. Please try again.',
          code: e.code,
        );
    }
  }

  @override
  String toString() => message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthException &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}
