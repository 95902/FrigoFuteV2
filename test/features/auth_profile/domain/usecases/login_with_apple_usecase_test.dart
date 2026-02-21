/// Unit tests for LoginWithAppleUseCase
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Tests cover:
/// - Successful sign-in → Right(UserEntity)
/// - User cancellation → Right(null) (not an error)
/// - Account deleted → Left(AuthException)
/// - Network error → Left(AuthException)
/// - Generic error → Left(AuthException) wrapped
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/apple_signin_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/user_entity.dart';
import 'package:frigofute_v2/features/auth_profile/domain/repositories/auth_repository.dart';
import 'package:frigofute_v2/features/auth_profile/domain/usecases/login_with_apple_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginWithAppleUseCase useCase;
  late MockAuthRepository mockRepository;

  final testUser = UserEntity(
    uid: 'apple-uid-123',
    email: 'user@privaterelay.appleid.com',
    emailVerified: true,
    firstName: 'Jean',
    lastName: 'Dupont',
    profileType: '',
    authProvider: 'apple',
    photoUrl: '',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginWithAppleUseCase(mockRepository);
  });

  group('LoginWithAppleUseCase', () {
    test('should return UserEntity on successful Apple sign-in', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<AuthException, UserEntity?>>());
      result.fold(
        (error) => fail('Expected Right but got Left: ${error.message}'),
        (user) {
          expect(user, isNotNull);
          expect(user!.uid, 'apple-uid-123');
          expect(user.email, 'user@privaterelay.appleid.com');
          expect(user.authProvider, 'apple');
          expect(user.photoUrl, isEmpty); // Apple never provides photos
        },
      );
    });

    test('should return null when user cancels sign-in (AC6)', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenThrow(AppleSignInCancelledException());

      // Act
      final result = await useCase.call();

      // Assert: Cancellation is NOT an error — returns Right(null)
      expect(result, isA<Right<AuthException, UserEntity?>>());
      result.fold(
        (error) => fail('Cancellation should not be an error'),
        (user) => expect(user, isNull),
      );
    });

    test('should return AuthException when account is deleted (AC9)', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenThrow(const AuthException(
        'This account has been deleted. Contact support to restore.',
        code: 'account-deleted',
      ));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error.code, 'account-deleted');
          expect(error.message, contains('deleted'));
        },
        (_) => fail('Expected Left but got Right'),
      );
    });

    test('should return AuthException on network error (AC7)', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenThrow(const AuthException(
        'Connection failed during sign-in. Please check your internet and try again.',
        code: 'network-request-failed',
      ));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) => expect(error.code, 'network-request-failed'),
        (_) => fail('Expected Left'),
      );
    });

    test('should return AuthException on Firebase Auth error', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenThrow(const AuthException(
        'Authentication failed. Please try again.',
        code: 'apple-signin-error',
      ));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), true);
    });

    test('should wrap generic exceptions in AuthException', () async {
      // Arrange
      when(() => mockRepository.loginWithApple())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (error) {
          expect(error.code, 'apple-signin-error');
          expect(error.message, contains('Apple sign-in failed'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('first-time user has empty profileType (triggers onboarding)', () async {
      // Arrange — first-time user with empty profileType
      final firstTimeUser = UserEntity(
        uid: 'apple-new-uid',
        email: 'newuser@privaterelay.appleid.com',
        emailVerified: true,
        firstName: 'Marie',
        lastName: 'Curie',
        profileType: '', // Empty → redirect to onboarding (AC2/AC6)
        authProvider: 'apple',
        photoUrl: '',
      );

      when(() => mockRepository.loginWithApple())
          .thenAnswer((_) async => firstTimeUser);

      // Act
      final result = await useCase.call();

      // Assert
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user, isNotNull);
          expect(user!.profileType, isEmpty); // Redirects to onboarding
        },
      );
    });

    test('returning user has set profileType (redirects to home)', () async {
      // Arrange — returning user with complete profile
      final returningUser = UserEntity(
        uid: 'apple-existing-uid',
        email: 'existing@privaterelay.appleid.com',
        emailVerified: true,
        firstName: 'Pierre',
        lastName: 'Martin',
        profileType: 'famille', // Non-empty → redirect to home (AC3/AC7)
        authProvider: 'apple',
        photoUrl: '',
      );

      when(() => mockRepository.loginWithApple())
          .thenAnswer((_) async => returningUser);

      // Act
      final result = await useCase.call();

      // Assert
      result.fold(
        (_) => fail('Expected Right'),
        (user) {
          expect(user, isNotNull);
          expect(user!.profileType, 'famille'); // Profile complete → home
        },
      );
    });
  });
}
