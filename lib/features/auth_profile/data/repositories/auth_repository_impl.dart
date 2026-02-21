import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/apple_signin_datasource.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';
import '../datasources/google_signin_datasource.dart';

/// Authentication repository implementation (data layer)
/// Story 1.1: Create Account with Email and Password
///
/// Coordinates Firebase Auth and Firestore operations.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreUserDataSource _firestoreDataSource;
  final GoogleSignInDataSource _googleSignInDataSource;
  final AppleSignInDataSource _appleSignInDataSource;

  AuthRepositoryImpl(
    this._authDataSource,
    this._firestoreDataSource,
    this._googleSignInDataSource,
    this._appleSignInDataSource,
  );

  @override
  Future<UserEntity> signUpWithEmail(String email, String password) async {
    UserCredential? userCredential;
    try {
      // 1. Create Firebase Auth user
      userCredential = await _authDataSource.signUpWithEmail(email, password);

      // 2. Create Firestore user document
      await _firestoreDataSource.createUserDocument(
        userCredential.user!.uid,
        email,
      );

      // 3. Send email verification
      await _authDataSource.sendEmailVerification(userCredential.user!);

      // 4. Return user entity
      return UserEntity.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      // Rollback: delete Firebase Auth user to avoid orphaned accounts
      // (user would be unable to log in OR re-register without this cleanup)
      if (userCredential != null) {
        try {
          await userCredential.user!.delete();
        } catch (_) {
          // Best-effort rollback — not critical enough to re-throw
        }
      }
      throw AuthException('Failed to create account: ${e.toString()}');
    }
  }

  // Story 1.2: Login with Email and Password

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      // 1. Authenticate with Firebase Auth
      final userCredential = await _authDataSource.signInWithEmail(
        email,
        password,
      );

      final firebaseUser = userCredential.user!;

      // 2. Fetch user profile from Firestore
      final userModel = await _firestoreDataSource.getUserById(firebaseUser.uid);

      // 3. Check if account is soft-deleted
      if (userModel.accountDeleted) {
        // Sign out immediately to prevent access
        await _authDataSource.signOut();

        throw const AuthException(
          'This account has been deleted. Contact support to restore.',
          code: 'account-deleted',
        );
      }

      // 4. Return user entity with Firestore data
      return UserEntity(
        uid: userModel.userId,
        email: userModel.email,
        emailVerified: firebaseUser.emailVerified,
        createdAt: userModel.createdAt,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        profileType: userModel.profileType,
        photoUrl: userModel.photoUrl,
        authProvider: userModel.authProvider,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } on AuthException {
      rethrow; // Already an AuthException (account-deleted case)
    } catch (e) {
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
      // M1: Also disconnect GoogleSignIn client to avoid stale session.
      // Safe no-op if user did not authenticate with Google.
      try {
        await _googleSignInDataSource.signOut();
      } catch (_) {
        // Best-effort — do not fail signOut if Google disconnect fails
      }
    } catch (e) {
      throw AuthException('Failed to sign out: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException('Failed to send password reset email: ${e.toString()}');
    }
  }

  // Story 1.3: Login with OAuth (Google Sign-In)

  @override
  Future<UserEntity> loginWithGoogle() async {
    try {
      // 1. Perform Google OAuth2 sign-in
      final userCredential = await _googleSignInDataSource.signInWithGoogle();
      final firebaseUser = userCredential.user!;

      // 2. Check if user document exists in Firestore
      try {
        final existingUser =
            await _firestoreDataSource.getUserById(firebaseUser.uid);

        // Returning user - check deletion status
        if (existingUser.accountDeleted) {
          await _googleSignInDataSource.signOut();
          throw const AuthException(
            'This account has been deleted. Contact support to restore.',
            code: 'account-deleted',
          );
        }

        // Return existing user with complete profile
        return UserEntity(
          uid: existingUser.userId,
          email: existingUser.email,
          emailVerified: firebaseUser.emailVerified,
          createdAt: existingUser.createdAt,
          firstName: existingUser.firstName,
          lastName: existingUser.lastName,
          profileType: existingUser.profileType,
          photoUrl: existingUser.photoUrl,
          authProvider: existingUser.authProvider,
        );
      } catch (e) {
        // Re-throw AuthException (e.g. account-deleted) — do NOT treat as first-time user
        if (e is AuthException) rethrow;

        // User document doesn't exist → First-time user
        // Fetch Google profile data
        final googleUser = _googleSignInDataSource.getCurrentGoogleUser();
        if (googleUser == null) {
          throw const AuthException('Google user data unavailable');
        }

        final googleProfile =
            _googleSignInDataSource.getUserProfile(googleUser);

        // Create new user document with Google profile data
        final newUserModel =
            await _firestoreDataSource.createUserDocumentFromGoogle(
          userId: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: googleProfile.displayName,
          photoUrl: googleProfile.photoUrl,
        );

        // Return new user entity
        return UserEntity(
          uid: newUserModel.userId,
          email: newUserModel.email,
          emailVerified: newUserModel.emailVerified,
          createdAt: newUserModel.createdAt,
          firstName: newUserModel.firstName,
          lastName: newUserModel.lastName,
          profileType: newUserModel.profileType,
          photoUrl: newUserModel.photoUrl,
          authProvider: newUserModel.authProvider,
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } on GoogleSignInCancelledException {
      // User cancelled - rethrow to be handled by use case
      rethrow;
    } on GoogleSignInException catch (e) {
      throw AuthException(e.message, code: e.code ?? 'google-signin-error');
    } on AuthException {
      rethrow; // Already an AuthException (account-deleted case)
    } catch (e) {
      throw AuthException('Google sign-in failed: ${e.toString()}');
    }
  }

  // Story 1.4: Login with OAuth Apple Sign-In

  @override
  Future<UserEntity> loginWithApple() async {
    try {
      // 1. Perform Apple OAuth2 sign-in (may throw AppleSignInCancelledException)
      final appleResult = await _appleSignInDataSource.signInWithApple();
      final firebaseUser = appleResult.userCredential.user!;

      // 2. Check if user document exists in Firestore
      try {
        final existingUser =
            await _firestoreDataSource.getUserById(firebaseUser.uid);

        // Returning user — check deletion status
        if (existingUser.accountDeleted) {
          await _appleSignInDataSource.signOut();
          throw const AuthException(
            'This account has been deleted. Contact support to restore.',
            code: 'account-deleted',
          );
        }

        // Return existing user with complete profile
        return UserEntity(
          uid: existingUser.userId,
          email: existingUser.email,
          emailVerified: true, // Apple pre-verifies emails
          createdAt: existingUser.createdAt,
          firstName: existingUser.firstName,
          lastName: existingUser.lastName,
          profileType: existingUser.profileType,
          photoUrl: '', // Apple never provides photos
          authProvider: existingUser.authProvider,
        );
      } catch (e) {
        // Re-throw AuthException (e.g. account-deleted) — not first-time user
        if (e is AuthException) rethrow;

        // First-time user — create Firestore document with Apple profile data
        // Note: givenName/familyName only available on FIRST sign-in
        final newUserModel =
            await _firestoreDataSource.createUserDocumentFromApple(
          userId: firebaseUser.uid,
          email: firebaseUser.email!,
          firstName: appleResult.firstName,
          lastName: appleResult.lastName,
        );

        return UserEntity(
          uid: newUserModel.userId,
          email: newUserModel.email,
          emailVerified: true,
          createdAt: newUserModel.createdAt,
          firstName: newUserModel.firstName,
          lastName: newUserModel.lastName,
          profileType: newUserModel.profileType,
          photoUrl: '',
          authProvider: 'apple',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } on AppleSignInCancelledException {
      // Rethrow to be handled by use case (returns Right(null))
      rethrow;
    } on AppleSignInException catch (e) {
      throw AuthException(e.message, code: e.code ?? 'apple-signin-error');
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Apple sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _authDataSource.currentUser;
    if (user == null) return null;
    return UserEntity.fromFirebaseUser(user);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _authDataSource.authStateChanges.map((user) {
      if (user == null) return null;
      return UserEntity.fromFirebaseUser(user);
    });
  }
}
