import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/core/exceptions/auth_exceptions.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/apple_signin_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firebase_auth_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firestore_user_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/google_signin_datasource.dart';
import 'package:frigofute_v2/features/auth_profile/data/repositories/auth_repository_impl.dart';
import 'package:frigofute_v2/features/auth_profile/domain/entities/user_entity.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  FirebaseAuthDataSource,
  FirestoreUserDataSource,
  GoogleSignInDataSource,
  AppleSignInDataSource,
  UserCredential,
  User,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockFirebaseAuthDataSource mockAuthDataSource;
  late MockFirestoreUserDataSource mockFirestoreDataSource;
  late MockGoogleSignInDataSource mockGoogleSignInDataSource;
  late MockAppleSignInDataSource mockAppleSignInDataSource;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuthDataSource = MockFirebaseAuthDataSource();
    mockFirestoreDataSource = MockFirestoreUserDataSource();
    mockGoogleSignInDataSource = MockGoogleSignInDataSource();
    mockAppleSignInDataSource = MockAppleSignInDataSource();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    repository = AuthRepositoryImpl(
      mockAuthDataSource,
      mockFirestoreDataSource,
      mockGoogleSignInDataSource,
      mockAppleSignInDataSource,
    );
  });

  group('AuthRepositoryImpl', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUserId = 'test-uid-123';

    group('signUpWithEmail()', () {
      setUp(() {
        // Default mock setup
        when(mockUser.uid).thenReturn(testUserId);
        when(mockUser.email).thenReturn(testEmail);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.metadata).thenReturn(MockUserMetadata());
        when(mockUserCredential.user).thenReturn(mockUser);
      });

      test('should create Firebase Auth user', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockFirestoreDataSource.createUserDocument(any, any))
            .thenAnswer((_) async => {});
        when(mockAuthDataSource.sendEmailVerification(any))
            .thenAnswer((_) async => {});

        // Act
        await repository.signUpWithEmail(testEmail, testPassword);

        // Assert
        verify(mockAuthDataSource.signUpWithEmail(testEmail, testPassword))
            .called(1);
      });

      test('should create Firestore user document after Firebase Auth', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockFirestoreDataSource.createUserDocument(any, any))
            .thenAnswer((_) async => {});
        when(mockAuthDataSource.sendEmailVerification(any))
            .thenAnswer((_) async => {});

        // Act
        await repository.signUpWithEmail(testEmail, testPassword);

        // Assert
        verify(mockFirestoreDataSource.createUserDocument(testUserId, testEmail))
            .called(1);
      });

      test('should send email verification after user creation', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockFirestoreDataSource.createUserDocument(any, any))
            .thenAnswer((_) async => {});
        when(mockAuthDataSource.sendEmailVerification(any))
            .thenAnswer((_) async => {});

        // Act
        await repository.signUpWithEmail(testEmail, testPassword);

        // Assert
        verify(mockAuthDataSource.sendEmailVerification(mockUser)).called(1);
      });

      test('should return UserEntity on successful signup', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockFirestoreDataSource.createUserDocument(any, any))
            .thenAnswer((_) async => {});
        when(mockAuthDataSource.sendEmailVerification(any))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.signUpWithEmail(testEmail, testPassword);

        // Assert
        expect(result, isA<UserEntity>());
        expect(result.uid, testUserId);
        expect(result.email, testEmail);
        expect(result.emailVerified, false);
      });

      test('should throw AuthException when Firebase Auth fails', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any)).thenThrow(
          FirebaseAuthException(code: 'email-already-in-use'),
        );

        // Act & Assert
        expect(
          () => repository.signUpWithEmail(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
      });

      test('should map FirebaseAuthException to AuthException', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any)).thenThrow(
          FirebaseAuthException(code: 'email-already-in-use'),
        );

        // Act & Assert
        try {
          await repository.signUpWithEmail(testEmail, testPassword);
          fail('Should have thrown AuthException');
        } on AuthException catch (e) {
          expect(e.code, 'email-already-in-use');
          expect(
            e.message,
            "This email is already registered. Use 'Forgot Password?' to recover.",
          );
        }
      });

      test('should throw AuthException when Firestore creation fails', () async {
        // Arrange
        when(mockAuthDataSource.signUpWithEmail(any, any))
            .thenAnswer((_) async => mockUserCredential);
        when(mockFirestoreDataSource.createUserDocument(any, any))
            .thenThrow(Exception('Firestore error'));

        // Act & Assert
        expect(
          () => repository.signUpWithEmail(testEmail, testPassword),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('getCurrentUser()', () {
      test('should return UserEntity when user is signed in', () async {
        // Arrange
        when(mockUser.uid).thenReturn(testUserId);
        when(mockUser.email).thenReturn(testEmail);
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUser.metadata).thenReturn(MockUserMetadata());
        when(mockAuthDataSource.currentUser).thenReturn(mockUser);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<UserEntity>());
        expect(result?.uid, testUserId);
        expect(result?.email, testEmail);
      });

      test('should return null when no user is signed in', () async {
        // Arrange
        when(mockAuthDataSource.currentUser).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, null);
      });
    });

    group('authStateChanges()', () {
      test('should emit UserEntity when user signs in', () async {
        // Arrange
        when(mockUser.uid).thenReturn(testUserId);
        when(mockUser.email).thenReturn(testEmail);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.metadata).thenReturn(MockUserMetadata());

        final userStream = Stream<User?>.value(mockUser);
        when(mockAuthDataSource.authStateChanges).thenAnswer((_) => userStream);

        // Act
        final stream = repository.authStateChanges();

        // Assert
        await expectLater(
          stream,
          emits(isA<UserEntity>()),
        );
      });

      test('should emit null when user signs out', () async {
        // Arrange
        final userStream = Stream<User?>.value(null);
        when(mockAuthDataSource.authStateChanges).thenAnswer((_) => userStream);

        // Act
        final stream = repository.authStateChanges();

        // Assert
        await expectLater(stream, emits(null));
      });
    });
  });
}

// Mock for UserMetadata
class MockUserMetadata extends Mock implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();
}
