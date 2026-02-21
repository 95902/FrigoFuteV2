import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:frigofute_v2/features/auth_profile/data/datasources/google_signin_datasource.dart';

import 'google_signin_datasource_test.mocks.dart';

@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseAuth,
  UserCredential,
  User,
])
void main() {
  late GoogleSignInDataSource dataSource;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignInAccount mockGoogleAccount;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleAccount = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    dataSource = GoogleSignInDataSource(mockGoogleSignIn, mockFirebaseAuth);
  });

  group('GoogleSignInDataSource', () {
    group('signInWithGoogle()', () {
      const testAccessToken = 'test_access_token';
      const testIdToken = 'test_id_token';

      test('should return UserCredential on successful sign-in', () async {
        // Arrange
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(mockGoogleAuth.accessToken).thenReturn(testAccessToken);
        when(mockGoogleAuth.idToken).thenReturn(testIdToken);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final result = await dataSource.signInWithGoogle();

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockGoogleSignIn.signIn()).called(1);
        verify(mockGoogleAccount.authentication).called(1);
        verify(mockFirebaseAuth.signInWithCredential(any)).called(1);
      });

      test('should throw GoogleSignInCancelledException when user cancels',
          () async {
        // Arrange
        when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        // Act & Assert — H1: async throws require await expectLater
        await expectLater(
          dataSource.signInWithGoogle(),
          throwsA(isA<GoogleSignInCancelledException>()),
        );
        verify(mockGoogleSignIn.signIn()).called(1);
        verifyNever(mockFirebaseAuth.signInWithCredential(any));
      });

      test('should throw GoogleSignInException on FirebaseAuthException',
          () async {
        // Arrange
        when(mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockGoogleAccount);
        when(mockGoogleAccount.authentication)
            .thenAnswer((_) async => mockGoogleAuth);
        when(mockGoogleAuth.accessToken).thenReturn(testAccessToken);
        when(mockGoogleAuth.idToken).thenReturn(testIdToken);
        when(mockFirebaseAuth.signInWithCredential(any))
            .thenThrow(FirebaseAuthException(code: 'user-disabled'));

        // Act & Assert — H1: async throws require await expectLater
        await expectLater(
          dataSource.signInWithGoogle(),
          throwsA(isA<GoogleSignInException>()),
        );
      });

      test('should throw GoogleSignInException on generic error', () async {
        // Arrange
        when(mockGoogleSignIn.signIn())
            .thenThrow(Exception('Network error'));

        // Act & Assert — H1: async throws require await expectLater
        await expectLater(
          dataSource.signInWithGoogle(),
          throwsA(isA<GoogleSignInException>()),
        );
      });
    });

    group('getCurrentGoogleUser()', () {
      test('should return current Google user when signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(mockGoogleAccount);

        // Act
        final result = dataSource.getCurrentGoogleUser();

        // Assert
        expect(result, equals(mockGoogleAccount));
        verify(mockGoogleSignIn.currentUser).called(1);
      });

      test('should return null when not signed in', () {
        // Arrange
        when(mockGoogleSignIn.currentUser).thenReturn(null);

        // Act
        final result = dataSource.getCurrentGoogleUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('signOut()', () {
      test('should sign out from both Google and Firebase', () async {
        // Arrange
        when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await dataSource.signOut();

        // Assert
        verify(mockGoogleSignIn.signOut()).called(1);
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('getUserProfile()', () {
      const testDisplayName = 'John Doe';
      const testEmail = 'john@example.com';
      const testPhotoUrl = 'https://example.com/photo.jpg';
      const testId = 'google-user-123';

      test('should extract profile data from GoogleSignInAccount', () {
        // Arrange
        when(mockGoogleAccount.displayName).thenReturn(testDisplayName);
        when(mockGoogleAccount.email).thenReturn(testEmail);
        when(mockGoogleAccount.photoUrl).thenReturn(testPhotoUrl);
        when(mockGoogleAccount.id).thenReturn(testId);

        // Act
        final result = dataSource.getUserProfile(mockGoogleAccount);

        // Assert
        expect(result.displayName, equals(testDisplayName));
        expect(result.email, equals(testEmail));
        expect(result.photoUrl, equals(testPhotoUrl));
        expect(result.id, equals(testId));
      });

      test('should handle null displayName gracefully', () {
        // Arrange
        when(mockGoogleAccount.displayName).thenReturn(null);
        when(mockGoogleAccount.email).thenReturn(testEmail);
        when(mockGoogleAccount.photoUrl).thenReturn(testPhotoUrl);
        when(mockGoogleAccount.id).thenReturn(testId);

        // Act
        final result = dataSource.getUserProfile(mockGoogleAccount);

        // Assert
        expect(result.displayName, equals(''));
        expect(result.email, equals(testEmail));
      });

      test('should handle null photoUrl gracefully', () {
        // Arrange
        when(mockGoogleAccount.displayName).thenReturn(testDisplayName);
        when(mockGoogleAccount.email).thenReturn(testEmail);
        when(mockGoogleAccount.photoUrl).thenReturn(null);
        when(mockGoogleAccount.id).thenReturn(testId);

        // Act
        final result = dataSource.getUserProfile(mockGoogleAccount);

        // Assert
        expect(result.photoUrl, isNull);
      });
    });
  });
}
