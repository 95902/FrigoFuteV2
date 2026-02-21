import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/signup_request_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/user_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/signup_usecase.dart';

import 'signup_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late SignupUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignupUseCase(mockRepository);
  });

  group('SignupUseCase', () {
    final testUserEntity = UserEntity(
      uid: 'test-uid-123',
      email: 'test@example.com',
      emailVerified: false,
      createdAt: DateTime.now(),
    );

    group('call()', () {
      test('should return UserEntity when signup succeeds', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: 'password123',
        );

        when(mockRepository.signUpWithEmail(any, any))
            .thenAnswer((_) async => testUserEntity);

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (error) => fail('Should not return error'),
          (user) {
            expect(user.uid, testUserEntity.uid);
            expect(user.email, testUserEntity.email);
          },
        );
        verify(mockRepository.signUpWithEmail('test@example.com', 'password123'))
            .called(1);
      });

      test('should return error when email is invalid', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'invalid-email',
          password: 'password123',
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'invalid-email');
            expect(error.message, 'Please enter a valid email address');
          },
          (user) => fail('Should not return user'),
        );
        verifyNever(mockRepository.signUpWithEmail(any, any));
      });

      test('should return error when email is empty', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: '',
          password: 'password123',
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'invalid-email');
            expect(error.message, 'Email is required');
          },
          (user) => fail('Should not return user'),
        );
        verifyNever(mockRepository.signUpWithEmail(any, any));
      });

      test('should return error when password is too short', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: '123', // Less than 8 characters
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'weak-password');
            expect(error.message, 'Password must be at least 8 characters');
          },
          (user) => fail('Should not return user'),
        );
        verifyNever(mockRepository.signUpWithEmail(any, any));
      });

      test('should return error when password is empty', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: '',
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'weak-password');
            expect(error.message, 'Password is required');
          },
          (user) => fail('Should not return user'),
        );
        verifyNever(mockRepository.signUpWithEmail(any, any));
      });

      test('should return error when password is too long', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: 'a' * 129, // More than 128 characters
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'weak-password');
            expect(error.message, 'Password must be less than 128 characters');
          },
          (user) => fail('Should not return user'),
        );
        verifyNever(mockRepository.signUpWithEmail(any, any));
      });

      test('should return error when repository throws AuthException', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: 'password123',
        );

        const authException = AuthException(
          'Email already in use',
          code: 'email-already-in-use',
        );

        when(mockRepository.signUpWithEmail(any, any))
            .thenThrow(authException);

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.code, 'email-already-in-use');
            expect(error.message, 'Email already in use');
          },
          (user) => fail('Should not return user'),
        );
      });

      test('should return error when repository throws unexpected exception',
          () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: 'password123',
        );

        when(mockRepository.signUpWithEmail(any, any))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (error) {
            expect(error.message, contains('Unexpected error'));
            expect(error.message, contains('Network error'));
          },
          (user) => fail('Should not return user'),
        );
      });

      test('should validate email before password', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'invalid-email',
          password: 'short', // Also invalid
        );

        // Act
        final result = await useCase.call(request);

        // Assert
        // Should fail on email validation first
        expect(result.isLeft(), true);
        result.fold(
          (error) => expect(error.code, 'invalid-email'),
          (user) => fail('Should not return user'),
        );
      });

      test('should accept valid email with special characters', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'user+test@example.co.uk',
          password: 'password123',
        );

        when(mockRepository.signUpWithEmail(any, any))
            .thenAnswer((_) async => testUserEntity);

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isRight(), true);
      });

      test('should accept valid 8-character password', () async {
        // Arrange
        final request = SignupRequestEntity(
          email: 'test@example.com',
          password: '12345678', // Exactly 8 characters
        );

        when(mockRepository.signUpWithEmail(any, any))
            .thenAnswer((_) async => testUserEntity);

        // Act
        final result = await useCase.call(request);

        // Assert
        expect(result.isRight(), true);
      });
    });
  });
}
