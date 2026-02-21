import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data source for Google Sign-In OAuth2 flow.
///
/// Handles:
/// - Google OAuth2 authentication
/// - Firebase credential creation
/// - Profile data extraction
/// - Sign-out coordination
class GoogleSignInDataSource {
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _firebaseAuth;

  GoogleSignInDataSource(this._googleSignIn, this._firebaseAuth);

  /// Signs in user with Google account via OAuth2.
  ///
  /// Flow:
  /// 1. Triggers Google Sign-In consent screen
  /// 2. Gets authentication tokens from Google
  /// 3. Creates Firebase credential
  /// 4. Signs in to Firebase with credential
  ///
  /// Throws [GoogleSignInCancelledException] if user cancels.
  /// Throws [GoogleSignInException] if sign-in fails.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In consent screen
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in flow
        throw GoogleSignInCancelledException('User cancelled Google Sign-In');
      }

      // 2. Get authentication tokens from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Validate tokens — both are nullable; null tokens produce a
      // cryptic Firebase INVALID_IDP_RESPONSE instead of a clear error.
      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        throw GoogleSignInException('Failed to get authentication tokens from Google');
      }

      // 4. Create Firebase credential from Google tokens
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 5. Sign in to Firebase with Google credential
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw GoogleSignInException(
        'Firebase Auth error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      if (e is GoogleSignInCancelledException) rethrow;
      throw GoogleSignInException('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Gets currently signed-in Google user (cached).
  ///
  /// Returns null if no user is signed in.
  GoogleSignInAccount? getCurrentGoogleUser() {
    return _googleSignIn.currentUser;
  }

  /// Signs out from both Google and Firebase.
  ///
  /// Ensures complete logout from both services.
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _firebaseAuth.signOut(),
    ]);
  }

  /// Gets Google user profile data (name, email, photo).
  ///
  /// Extracts profile information from Google account.
  GoogleUserProfile getUserProfile(GoogleSignInAccount googleUser) {
    return GoogleUserProfile(
      displayName: googleUser.displayName ?? '',
      email: googleUser.email,
      photoUrl: googleUser.photoUrl,
      id: googleUser.id,
    );
  }
}

/// Google user profile data extracted from OAuth.
class GoogleUserProfile {
  final String displayName;
  final String email;
  final String? photoUrl;
  final String id;

  GoogleUserProfile({
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.id,
  });
}

/// Exception thrown when Google Sign-In fails.
class GoogleSignInException implements Exception {
  final String message;
  final String? code;

  GoogleSignInException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Exception thrown when user cancels Google Sign-In.
///
/// This is NOT an error condition - user cancellation is expected behavior.
class GoogleSignInCancelledException implements Exception {
  final String message;

  GoogleSignInCancelledException(this.message);

  @override
  String toString() => message;
}
