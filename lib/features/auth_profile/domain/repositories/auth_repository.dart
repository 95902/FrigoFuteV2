import '../entities/user_entity.dart';

/// Authentication repository interface (domain layer)
/// Story 1.1: Create Account with Email and Password
///
/// Defines the contract for authentication operations.
/// Implementations handle Firebase Auth + Firestore.
abstract class AuthRepository {
  /// Creates a new user account with email and password.
  ///
  /// Flow:
  /// 1. Creates Firebase Auth user
  /// 2. Creates Firestore user document
  /// 3. Sends email verification
  /// 4. Returns user entity
  ///
  /// Throws [AuthException] if signup fails.
  Future<UserEntity> signUpWithEmail(String email, String password);

  /// Signs in user with email and password.
  ///
  /// Story 1.2: Login with Email and Password
  /// (To be implemented)
  Future<UserEntity> signInWithEmail(String email, String password);

  /// Signs out the current user.
  ///
  /// Story 1.2: Login with Email and Password
  /// (To be implemented)
  Future<void> signOut();

  /// Sends password reset email.
  ///
  /// Story 1.2: Login with Email and Password
  /// (To be implemented)
  Future<void> sendPasswordResetEmail(String email);

  /// Signs in user with Google OAuth2.
  ///
  /// Story 1.3: Login with OAuth (Google Sign-In)
  ///
  /// Flow:
  /// 1. Triggers Google OAuth2 consent screen
  /// 2. Creates/fetches Firestore user document
  /// 3. Returns user entity with Google profile data
  ///
  /// Throws [AuthException] if sign-in fails.
  Future<UserEntity> loginWithGoogle();

  /// Signs in user with Apple OAuth2.
  ///
  /// Story 1.4: Login with OAuth Apple Sign-In
  ///
  /// Flow:
  /// 1. Opens Apple ID authentication (Face ID/Touch ID)
  /// 2. Creates/fetches Firestore user document
  /// 3. Returns user entity with Apple profile data
  ///
  /// Privacy notes:
  /// - Email may be Apple private relay (xyz@privaterelay.appleid.com)
  /// - Name only available on first sign-in
  /// - No profile photo from Apple
  ///
  /// Throws [AuthException] if sign-in fails.
  /// Caller must catch [AppleSignInCancelledException] for graceful cancellation handling.
  Future<UserEntity> loginWithApple();

  /// Gets the current authenticated user.
  ///
  /// Returns `null` if no user is signed in.
  Future<UserEntity?> getCurrentUser();

  /// Stream of authentication state changes.
  ///
  /// Emits `UserEntity?` whenever the auth state changes.
  Stream<UserEntity?> authStateChanges();
}
