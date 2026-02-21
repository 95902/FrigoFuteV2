import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/password_reset_usecase.dart';

import 'password_reset_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late PasswordResetUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = PasswordResetUseCase(mockRepository);
  });

  group('PasswordResetUseCase', () {
    const testEmail = 'user@example.com';

    test('should return Right(void) on successful password reset email sent',
        () async {
      // Arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await useCase.call(testEmail);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Expected Right but got Left: $error'),
        (_) {
          // Success - void return
        },
      );
      verify(mockRepository.sendPasswordResetEmail(testEmail)).called(1);
    });

    test('should return Left(AuthException) for invalid email format',
        () async {
      // Arrange
      const invalidEmail = 'invalid-email';

      // Act
      final result = await useCase.call(invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
          expect(error.message, 'Please enter a valid email address');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });

    test('should return Left(AuthException) for empty email', () async {
      // Arrange
      const emptyEmail = '';

      // Act
      final result = await useCase.call(emptyEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
          expect(error.message, 'Email is required');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });

    test('should return Left(AuthException) for network error', () async {
      // Arrange
      when(mockRepository.sendPasswordResetEmail(any)).thenThrow(
        const AuthException(
          'Connection failed. Please check your internet and try again.',
          code: 'network-request-failed',
        ),
      );

      // Act
      final result = await useCase.call(testEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'network-request-failed');
          expect(
            error.message,
            'Connection failed. Please check your internet and try again.',
          );
        },
        (_) => fail('Expected Left but got Right'),
      );
      verify(mockRepository.sendPasswordResetEmail(testEmail)).called(1);
    });

    test('should return Left(AuthException) for unexpected error', () async {
      // Arrange
      when(mockRepository.sendPasswordResetEmail(any))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call(testEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.message, contains('Unexpected error'));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should not reveal if user exists (privacy protection)', () async {
      // Firebase Auth doesn't throw error if user doesn't exist
      // (privacy protection - prevents user enumeration)

      // Arrange
      const nonexistentEmail = 'nonexistent@example.com';
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await useCase.call(nonexistentEmail);

      // Assert
      expect(result.isRight(), true);
      // Success even if user doesn't exist (privacy protection)
      verify(mockRepository.sendPasswordResetEmail(nonexistentEmail)).called(1);
    });

    test('should reject email with leading/trailing whitespace', () async {
      // Arrange
      const emailWithWhitespace = '  user@example.com  ';

      // Act
      final result = await useCase.call(emailWithWhitespace);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });

    test('should accept email with uppercase (normalized by validator)',
        () async {
      // Arrange
      const uppercaseEmail = 'USER@EXAMPLE.COM';
      when(mockRepository.sendPasswordResetEmail(any))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await useCase.call(uppercaseEmail);

      // Assert
      expect(result.isRight(), true);
      verify(mockRepository.sendPasswordResetEmail(uppercaseEmail)).called(1);
    });

    test('should handle missing @ symbol in email', () async {
      // Arrange
      const invalidEmail = 'userexample.com';

      // Act
      final result = await useCase.call(invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });

    test('should handle missing domain in email', () async {
      // Arrange
      const invalidEmail = 'user@';

      // Act
      final result = await useCase.call(invalidEmail);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.sendPasswordResetEmail(any));
    });
  });
}
