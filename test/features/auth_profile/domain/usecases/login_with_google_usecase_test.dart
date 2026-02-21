import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/google_signin_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/user_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/login_with_google_usecase.dart';

import 'login_with_google_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginWithGoogleUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithGoogleUseCase(mockRepository);
  });

  group('LoginWithGoogleUseCase', () {
    final testUser = UserEntity(
      uid: 'test-uid-123',
      email: 'john@example.com',
      emailVerified: true,
      createdAt: DateTime(2024, 1, 1),
      firstName: 'John',
      lastName: 'Doe',
      profileType: '',
      photoUrl: 'https://example.com/photo.jpg',
      authProvider: 'google',
    );

    test('should return UserEntity on successful Google sign-in', () async {
      // Arrange
      when(mockRepository.loginWithGoogle())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(Right(testUser)));
      verify(mockRepository.loginWithGoogle()).called(1);
    });

    test('should return null when user cancels sign-in', () async {
      // Arrange
      when(mockRepository.loginWithGoogle())
          .thenThrow(GoogleSignInCancelledException('User cancelled'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(const Right(null)));
      verify(mockRepository.loginWithGoogle()).called(1);
    });

    test('should return AuthException when account is deleted', () async {
      // Arrange
      const exception = AuthException(
        'This account has been deleted. Contact support to restore.',
        code: 'account-deleted',
      );
      when(mockRepository.loginWithGoogle()).thenThrow(exception);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (error) {
          expect(error.message, equals(exception.message));
          expect(error.code, equals('account-deleted'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return AuthException on network error', () async {
      // Arrange
      const exception = AuthException(
        'Network error occurred',
        code: 'network-error',
      );
      when(mockRepository.loginWithGoogle()).thenThrow(exception);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (error) {
          expect(error.message, contains('Network error'));
          expect(error.code, equals('network-error'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return AuthException on Firebase Auth error', () async {
      // Arrange
      const exception = AuthException(
        'Firebase Auth error',
        code: 'firebase-error',
      );
      when(mockRepository.loginWithGoogle()).thenThrow(exception);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (error) => expect(error.message, contains('Firebase Auth')),
        (_) => fail('Should return Left'),
      );
    });

    test('should wrap generic exceptions in AuthException', () async {
      // Arrange
      when(mockRepository.loginWithGoogle())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (error) {
          expect(error.message, contains('Google sign-in failed'));
          expect(error.code, equals('google-signin-error'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should return user with Google profile data for first-time user',
        () async {
      // Arrange - First-time user with empty profileType
      final firstTimeUser = UserEntity(
        uid: 'new-user-123',
        email: 'newuser@example.com',
        emailVerified: true,
        createdAt: DateTime.now(),
        firstName: 'New',
        lastName: 'User',
        profileType: '', // Empty for first-time user
        photoUrl: 'https://example.com/new-photo.jpg',
        authProvider: 'google',
      );
      when(mockRepository.loginWithGoogle())
          .thenAnswer((_) async => firstTimeUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user, isNotNull);
          expect(user!.authProvider, equals('google'));
          expect(user.emailVerified, isTrue);
          expect(user.photoUrl, isNotEmpty);
          expect(user.profileType, isEmpty); // Should redirect to onboarding
        },
      );
    });

    test('should return user with complete profile for returning user',
        () async {
      // Arrange - Returning user with profileType set
      final returningUser = UserEntity(
        uid: 'existing-user-123',
        email: 'existing@example.com',
        emailVerified: true,
        createdAt: DateTime(2023, 1, 1),
        firstName: 'Existing',
        lastName: 'User',
        profileType: 'Famille', // Profile complete
        photoUrl: 'https://example.com/existing-photo.jpg',
        authProvider: 'google',
      );
      when(mockRepository.loginWithGoogle())
          .thenAnswer((_) async => returningUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should return Right'),
        (user) {
          expect(user, isNotNull);
          expect(user!.profileType, equals('Famille'));
          expect(user.authProvider, equals('google'));
        },
      );
    });
  });
}
