import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/firebase_auth_datasource.dart';

import 'firebase_auth_datasource_test.mocks.dart';

@GenerateMocks([FirebaseAuth, UserCredential, User])
void main() {
  late FirebaseAuthDataSource dataSource;
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    dataSource = FirebaseAuthDataSource(mockAuth);
  });

  group('FirebaseAuthDataSource', () {
    group('signUpWithEmail()', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should call createUserWithEmailAndPassword with correct parameters',
          () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        await dataSource.signUpWithEmail(testEmail, testPassword);

        // Assert
        verify(mockAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        )).called(1);
      });

      test('should return UserCredential on successful signup', () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await dataSource.signUpWithEmail(testEmail, testPassword);

        // Assert
        expect(result, mockUserCredential);
      });

      test('should throw FirebaseAuthException when email is already in use',
          () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email already in use',
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.signUpWithEmail(testEmail, testPassword),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('should throw FirebaseAuthException when password is weak',
          () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(
          FirebaseAuthException(
            code: 'weak-password',
            message: 'Password is too weak',
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.signUpWithEmail(testEmail, 'weak'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('sendEmailVerification()', () {
      test('should call sendEmailVerification when user is not verified',
          () async {
        // Arrange
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

        // Act
        await dataSource.sendEmailVerification(mockUser);

        // Assert
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should not call sendEmailVerification when user is already verified',
          () async {
        // Arrange
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        await dataSource.sendEmailVerification(mockUser);

        // Assert
        verifyNever(mockUser.sendEmailVerification());
      });
    });

    group('resendEmailVerification()', () {
      test('should call sendEmailVerification on current user', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(false);
        when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

        // Act
        await dataSource.resendEmailVerification();

        // Assert
        verify(mockUser.sendEmailVerification()).called(1);
      });

      test('should not send verification if user is already verified', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.emailVerified).thenReturn(true);

        // Act
        await dataSource.resendEmailVerification();

        // Assert
        verifyNever(mockUser.sendEmailVerification());
      });

      test('should not throw if no user is signed in', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert (should not throw)
        await dataSource.resendEmailVerification();
      });
    });

    group('currentUser', () {
      test('should return current user from FirebaseAuth', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = dataSource.currentUser;

        // Assert
        expect(result, mockUser);
      });

      test('should return null when no user is signed in', () {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act
        final result = dataSource.currentUser;

        // Assert
        expect(result, null);
      });
    });

    group('authStateChanges', () {
      test('should return stream from FirebaseAuth', () {
        // Arrange
        final testStream = Stream<User?>.value(mockUser);
        when(mockAuth.authStateChanges()).thenAnswer((_) => testStream);

        // Act
        final result = dataSource.authStateChanges;

        // Assert
        expect(result, testStream);
      });
    });
  });
}
