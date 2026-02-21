import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';

void main() {
  group('AuthException', () {
    test('should create exception with message and code', () {
      const exception = AuthException('Test error', code: 'test-code');

      expect(exception.message, 'Test error');
      expect(exception.code, 'test-code');
      expect(exception.toString(), 'Test error');
    });

    test('should use default code "unknown" if not provided', () {
      const exception = AuthException('Test error');

      expect(exception.code, 'unknown');
    });

    group('fromFirebaseAuthException()', () {
      test('should map email-already-in-use error', () {
        final firebaseException = FirebaseAuthException(
          code: 'email-already-in-use',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'email-already-in-use');
        expect(
          exception.message,
          "This email is already registered. Use 'Forgot Password?' to recover.",
        );
      });

      test('should map invalid-email error', () {
        final firebaseException = FirebaseAuthException(
          code: 'invalid-email',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'invalid-email');
        expect(exception.message, 'Please enter a valid email address.');
      });

      test('should map weak-password error', () {
        final firebaseException = FirebaseAuthException(
          code: 'weak-password',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'weak-password');
        expect(
          exception.message,
          'Password is too weak. Use at least 8 characters.',
        );
      });

      test('should map network-request-failed error', () {
        final firebaseException = FirebaseAuthException(
          code: 'network-request-failed',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'network-request-failed');
        expect(
          exception.message,
          'Connection failed. Please check your internet and try again.',
        );
      });

      test('should map too-many-requests error', () {
        final firebaseException = FirebaseAuthException(
          code: 'too-many-requests',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'too-many-requests');
        expect(
          exception.message,
          'Too many attempts. Please try again later.',
        );
      });

      test('should map operation-not-allowed error', () {
        final firebaseException = FirebaseAuthException(
          code: 'operation-not-allowed',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'operation-not-allowed');
        expect(
          exception.message,
          'Email/password authentication is currently disabled.',
        );
      });

      test('should map user-disabled error', () {
        final firebaseException = FirebaseAuthException(
          code: 'user-disabled',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'user-disabled');
        expect(exception.message, 'This account has been disabled.');
      });

      test('should handle unknown error codes', () {
        final firebaseException = FirebaseAuthException(
          code: 'some-unknown-error',
        );

        final exception =
            AuthException.fromFirebaseAuthException(firebaseException);

        expect(exception.code, 'some-unknown-error');
        expect(exception.message, 'Something went wrong. Please try again.');
      });
    });

    group('equality', () {
      test('should be equal when message and code are the same', () {
        const exception1 = AuthException('Test', code: 'test');
        const exception2 = AuthException('Test', code: 'test');

        expect(exception1, exception2);
        expect(exception1.hashCode, exception2.hashCode);
      });

      test('should not be equal when message differs', () {
        const exception1 = AuthException('Test1', code: 'test');
        const exception2 = AuthException('Test2', code: 'test');

        expect(exception1, isNot(exception2));
      });

      test('should not be equal when code differs', () {
        const exception1 = AuthException('Test', code: 'test1');
        const exception2 = AuthException('Test', code: 'test2');

        expect(exception1, isNot(exception2));
      });
    });
  });
}
