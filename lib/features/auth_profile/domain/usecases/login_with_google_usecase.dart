import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../data/datasources/google_signin_datasource.dart';

/// Login with Google OAuth2 use case.
///
/// Story 1.3: Login with OAuth (Google Sign-In)
///
/// Handles Google OAuth2 authentication flow and returns user profile.
/// Supports both first-time and returning users.
class LoginWithGoogleUseCase {
  final AuthRepository _repository;

  LoginWithGoogleUseCase(this._repository);

  /// Logs in user with Google OAuth2 and returns user profile.
  ///
  /// Handles:
  /// - First-time user: Creates Firestore document with Google profile data
  /// - Returning user: Fetches existing profile
  /// - Account deleted: Returns error
  /// - User cancellation: Returns null (not an error)
  ///
  /// Returns:
  /// - Right(UserEntity): Successful login
  /// - Right(null): User cancelled (not an error)
  /// - Left(AuthException): Authentication failed
  Future<Either<AuthException, UserEntity?>> call() async {
    try {
      // Authenticate with Google OAuth
      final user = await _repository.loginWithGoogle();

      return Right(user);
    } on GoogleSignInCancelledException {
      // User cancelled - not an error, return null
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          'Google sign-in failed: ${e.toString()}',
          code: 'google-signin-error',
        ),
      );
    }
  }
}
