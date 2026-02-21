import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../data/datasources/apple_signin_datasource.dart';

/// Login with Apple use case
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Handles Apple OAuth2 authentication:
/// - First-time user: Creates Firestore document with Apple profile data
/// - Returning user: Fetches existing profile
/// - Cancellation: Returns Right(null) — not an error
/// - Account deleted: Returns Left(AuthException)
class LoginWithAppleUseCase {
  final AuthRepository _repository;

  LoginWithAppleUseCase(this._repository);

  /// Logs in user with Apple OAuth2.
  ///
  /// Returns:
  /// - [Right(UserEntity)] on successful sign-in
  /// - [Right(null)] when user cancels (expected behavior, not an error)
  /// - [Left(AuthException)] on authentication failure
  Future<Either<AuthException, UserEntity?>> call() async {
    try {
      final user = await _repository.loginWithApple();
      return Right(user);
    } on AppleSignInCancelledException {
      // User cancelled — not an error, return null
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException(
          'Apple sign-in failed: ${e.toString()}',
          code: 'apple-signin-error',
        ),
      );
    }
  }
}
