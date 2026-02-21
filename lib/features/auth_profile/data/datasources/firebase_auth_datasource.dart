import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication data source
/// Story 1.1: Create Account with Email and Password
///
/// Handles Firebase Auth operations (signup, email verification).
class FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSource(this._auth);

  /// Creates a new user with email and password.
  ///
  /// Throws [FirebaseAuthException] if signup fails:
  /// - `email-already-in-use`: Email is already registered
  /// - `invalid-email`: Email format is invalid
  /// - `weak-password`: Password is too weak (< 6 chars by Firebase)
  /// - `network-request-failed`: No internet connection
  ///
  /// Returns [UserCredential] with user information.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sends email verification to the user.
  ///
  /// The user receives an email with a verification link.
  /// Clicking the link updates `emailVerified` to true in Firebase Auth.
  ///
  /// Throws [FirebaseAuthException] if sending fails.
  Future<void> sendEmailVerification(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Resends email verification (for users who didn't receive it).
  ///
  /// Can be called from UI when user clicks "Resend verification email".
  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Gets the current authenticated user.
  ///
  /// Returns `null` if no user is signed in.
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  ///
  /// Emits `User?` whenever the auth state changes:
  /// - User signs in → emits User
  /// - User signs out → emits null
  /// - Email verification status changes → emits updated User
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Story 1.2: Login with Email and Password

  /// Signs in user with email and password.
  ///
  /// Throws [FirebaseAuthException] if login fails:
  /// - `user-not-found`: No user exists with this email
  /// - `wrong-password`: Password is incorrect
  /// - `user-disabled`: Account has been disabled by admin
  /// - `too-many-requests`: Too many failed login attempts (rate limiting)
  /// - `network-request-failed`: No internet connection
  ///
  /// Returns [UserCredential] with user information.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  ///
  /// Clears the local session and invalidates tokens.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Sends password reset email to the user.
  ///
  /// Firebase sends an email with a link to reset the password.
  /// The link opens a Firebase-hosted page where user can set a new password.
  ///
  /// Throws [FirebaseAuthException] if sending fails:
  /// - `invalid-email`: Email format is invalid
  /// - `user-not-found`: No user exists with this email (but we don't reveal this to client)
  ///
  /// Note: Firebase doesn't reveal if email exists (privacy protection).
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Checks if current user's email is verified.
  ///
  /// Returns `false` if no user is signed in.
  bool isEmailVerified() {
    final user = _auth.currentUser;
    return user?.emailVerified ?? false;
  }
}
