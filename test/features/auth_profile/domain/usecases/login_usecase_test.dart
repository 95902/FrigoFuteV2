import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/login_request_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/user_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const testEmail = 'user@example.com';
    const testPassword = 'password123';
    final testUser = UserEntity(
      uid: 'abc123',
      email: testEmail,
      emailVerified: true,
      createdAt: DateTime(2024, 1, 1),
      firstName: 'John',
      lastName: 'Doe',
      profileType: 'Famille',
    );

    test('should return Right(UserEntity) on successful login', () async {
      // Arrange
      final request = LoginRequestEntity(email: testEmail, password: testPassword);
      when(mockRepository.signInWithEmail(any, any))
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (error) => fail('Expected Right but got Left: $error'),
        (user) {
          expect(user, testUser);
          expect(user.email, testEmail);
          expect(user.profileType, 'Famille');
        },
      );
      verify(mockRepository.signInWithEmail(testEmail, testPassword)).called(1);
    });

    test('should return Left(AuthException) for invalid email format', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: 'invalid-email',
        password: testPassword,
      );

      // Act
      final result = await useCase.call(request);

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
      verifyNever(mockRepository.signInWithEmail(any, any));
    });

    test('should return Left(AuthException) for empty password', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: testEmail,
        password: '',
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'empty-password');
          expect(error.message, 'Password is required');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.signInWithEmail(any, any));
    });

    test('should return Left(AuthException) for wrong password', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: testEmail,
        password: 'wrongpassword',
      );
      when(mockRepository.signInWithEmail(any, any)).thenThrow(
        const AuthException(
          'Incorrect email or password. Please try again.',
          code: 'invalid-credentials',
        ),
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-credentials');
          expect(
            error.message,
            'Incorrect email or password. Please try again.',
          );
        },
        (_) => fail('Expected Left but got Right'),
      );
      verify(mockRepository.signInWithEmail(testEmail, 'wrongpassword'))
          .called(1);
    });

    test('should return Left(AuthException) for user-not-found error',
        () async {
      // Arrange
      final request = LoginRequestEntity(
        email: 'nonexistent@example.com',
        password: testPassword,
      );
      when(mockRepository.signInWithEmail(any, any)).thenThrow(
        const AuthException(
          'Incorrect email or password. Please try again.',
          code: 'invalid-credentials',
        ),
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-credentials');
          // Generic message to prevent user enumeration
          expect(
            error.message,
            'Incorrect email or password. Please try again.',
          );
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(AuthException) for deleted account', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: 'deleted@example.com',
        password: testPassword,
      );
      when(mockRepository.signInWithEmail(any, any)).thenThrow(
        const AuthException(
          'This account has been deleted. Contact support to restore.',
          code: 'account-deleted',
        ),
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'account-deleted');
          expect(
            error.message,
            'This account has been deleted. Contact support to restore.',
          );
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(AuthException) for too-many-requests error',
        () async {
      // Arrange
      final request = LoginRequestEntity(
        email: testEmail,
        password: testPassword,
      );
      when(mockRepository.signInWithEmail(any, any)).thenThrow(
        const AuthException(
          'Too many login attempts. Please try again in 5 minutes.',
          code: 'too-many-requests',
        ),
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'too-many-requests');
          expect(
            error.message,
            'Too many login attempts. Please try again in 5 minutes.',
          );
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return Left(AuthException) for network error', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: testEmail,
        password: testPassword,
      );
      when(mockRepository.signInWithEmail(any, any)).thenThrow(
        const AuthException(
          'Connection failed. Please check your internet and try again.',
          code: 'network-request-failed',
        ),
      );

      // Act
      final result = await useCase.call(request);

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
    });

    test('should return Left(AuthException) for unexpected error', () async {
      // Arrange
      final request = LoginRequestEntity(
        email: testEmail,
        password: testPassword,
      );
      when(mockRepository.signInWithEmail(any, any))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call(request);

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

    test('should reject malformed email format', () async {
      // Arrange
      // Note: after Story 1-1 trim fix, whitespace is stripped before validation.
      // Test uses a genuinely malformed email to verify format validation.
      final request = LoginRequestEntity(
        email: 'not-a-valid-email',
        password: testPassword,
      );

      // Act
      final result = await useCase.call(request);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error, isA<AuthException>());
          expect(error.code, 'invalid-email');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verifyNever(mockRepository.signInWithEmail(any, any));
    });
  });
}
