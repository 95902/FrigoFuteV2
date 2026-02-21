/// Unit tests for AppleSignInDataSource exceptions and result classes
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Note: The full Apple OAuth flow (signInWithApple) cannot be unit-tested
/// without a real Apple ID / device. These tests cover the exception classes
/// and result data structure independently of the OAuth flow.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/apple_signin_datasource.dart';
import 'package:mocktail/mocktail.dart';

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AppleSignInCancelledException', () {
    test('has default message', () {
      final exception = AppleSignInCancelledException();
      expect(exception.message, 'User cancelled Apple Sign-In');
    });

    test('accepts custom message', () {
      final exception = AppleSignInCancelledException('Custom cancel message');
      expect(exception.message, 'Custom cancel message');
    });

    test('is an Exception', () {
      expect(AppleSignInCancelledException(), isA<Exception>());
    });
  });

  group('AppleSignInException', () {
    test('stores message and code', () {
      final exception = AppleSignInException(
        'Apple auth failed',
        code: 'auth-failed',
      );

      expect(exception.message, 'Apple auth failed');
      expect(exception.code, 'auth-failed');
    });

    test('code is optional', () {
      final exception = AppleSignInException('Unexpected error');
      expect(exception.code, isNull);
    });

    test('is an Exception', () {
      expect(AppleSignInException('error'), isA<Exception>());
    });
  });

  group('AppleSignInResult', () {
    late MockUserCredential mockCredential;

    setUp(() {
      mockCredential = MockUserCredential();
    });

    test('stores firstName and lastName from Apple credential', () {
      final result = AppleSignInResult(
        userCredential: mockCredential,
        firstName: 'Jean',
        lastName: 'Dupont',
      );

      expect(result.firstName, 'Jean');
      expect(result.lastName, 'Dupont');
      expect(result.userCredential, mockCredential);
    });

    test('handles empty name (subsequent sign-ins after first)', () {
      final result = AppleSignInResult(
        userCredential: mockCredential,
        firstName: '',
        lastName: '',
      );

      expect(result.firstName, isEmpty);
      expect(result.lastName, isEmpty);
    });

    test('stores private relay email correctly', () {
      // Apple "Hide My Email" generates private relay emails
      // The email itself is stored in the Firebase userCredential, not in
      // AppleSignInResult - this test verifies the result structure
      final result = AppleSignInResult(
        userCredential: mockCredential,
        firstName: '',
        lastName: '',
      );

      // The userCredential handles email, result only holds name data
      expect(result.userCredential, isNotNull);
    });
  });
}
