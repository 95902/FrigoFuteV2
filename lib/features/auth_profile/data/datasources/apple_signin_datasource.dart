import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Result from Apple Sign-In combining Firebase UserCredential and Apple name data.
///
/// Apple only provides name (givenName/familyName) on the FIRST sign-in.
/// Subsequent sign-ins return null for name fields.
class AppleSignInResult {
  final UserCredential userCredential;

  /// First name from Apple (only available on first sign-in, empty otherwise).
  final String firstName;

  /// Last name from Apple (only available on first sign-in, empty otherwise).
  final String lastName;

  AppleSignInResult({
    required this.userCredential,
    required this.firstName,
    required this.lastName,
  });
}

/// Exception thrown when user cancels Apple Sign-In.
class AppleSignInCancelledException implements Exception {
  final String message;
  AppleSignInCancelledException([this.message = 'User cancelled Apple Sign-In']);
}

/// Exception thrown when Apple Sign-In fails.
class AppleSignInException implements Exception {
  final String message;
  final String? code;
  AppleSignInException(this.message, {this.code});
}

/// Apple Sign-In data source
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Handles Apple OAuth2 flow using the sign_in_with_apple package.
///
/// Platform support:
/// - iOS 13.0+ (native support)
/// - macOS 10.15+ (native support)
/// - Android: NOT supported for MVP (button hidden on Android)
///
/// Privacy:
/// - User can share real email OR use "Hide My Email" (private relay)
/// - Full name only provided on FIRST sign-in
/// - Apple does NOT provide profile photos
class AppleSignInDataSource {
  final FirebaseAuth _auth;

  AppleSignInDataSource(this._auth);

  /// Signs in user with Apple OAuth2.
  ///
  /// Flow:
  /// 1. Opens Apple authentication (Face ID / Touch ID)
  /// 2. User chooses email sharing (real or Hide My Email)
  /// 3. User shares name (first sign-in only)
  /// 4. Creates Firebase Auth credential from Apple token
  /// 5. Signs in to Firebase with Apple credential
  ///
  /// Returns [AppleSignInResult] with Firebase user + Apple name data.
  ///
  /// Throws:
  /// - [AppleSignInCancelledException] if user cancels (expected behavior, not an error)
  /// - [AppleSignInException] if authentication fails
  Future<AppleSignInResult> signInWithApple() async {
    try {
      // Step 1: Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Step 2: Validate Apple identity token — null token produces a cryptic
      // Firebase INVALID_IDP_RESPONSE instead of a clear error (mirror of
      // Google sign-in M3 fix).
      if (appleCredential.identityToken == null) {
        throw AppleSignInException(
          'Failed to get identity token from Apple. Please try again.',
        );
      }

      // Step 3: Create Firebase OAuth credential from Apple tokens
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Step 4: Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oAuthCredential);

      // Extract name (only available on first sign-in)
      return AppleSignInResult(
        userCredential: userCredential,
        firstName: appleCredential.givenName ?? '',
        lastName: appleCredential.familyName ?? '',
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw AppleSignInCancelledException();
      }
      throw AppleSignInException(
        'Apple Sign-In failed: ${e.message}',
        code: e.code.toString(),
      );
    } on AppleSignInCancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      // M4: Map Firebase errors to user-friendly messages (AC8: cross-provider conflict)
      final message = e.code == 'account-exists-with-different-credential'
          ? 'This email is already linked to another sign-in method. Try signing in differently.'
          : 'Authentication failed: ${e.message}';
      throw AppleSignInException(message, code: e.code);
    } catch (e) {
      throw AppleSignInException('Unexpected error during Apple Sign-In: $e');
    }
  }

  /// Signs out from Firebase Auth.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
