import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/validation/email_validator.dart';
import '../entities/login_request_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login use case (domain layer)
/// Story 1.2: Login with Email and Password
///
/// Validates input, authenticates with Firebase Auth,
/// checks account deletion status, returns user profile.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Logs in user and returns user profile.
  ///
  /// Flow:
  /// 1. Validate email format
  /// 2. Validate password not empty
  /// 3. Authenticate with Firebase Auth
  /// 4. Fetch Firestore user profile
  /// 5. Check account deletion status
  /// 6. Return user entity
  ///
  /// Returns [Right(UserEntity)] on success.
  /// Returns [Left(AuthException)] on failure.
  Future<Either<AuthException, UserEntity>> call(
    LoginRequestEntity request,
  ) async {
    try {
      // 1. Validate email format
      final emailError = EmailValidator.validate(request.email);
      if (emailError != null) {
        return Left(AuthException(emailError, code: 'invalid-email'));
      }

      // 2. Validate password not empty
      if (request.password.isEmpty) {
        return const Left(
          AuthException('Password is required', code: 'empty-password'),
        );
      }

      // 3. Authenticate and fetch profile (repository handles Firestore fetch)
      final user = await _repository.signInWithEmail(
        request.email,
        request.password,
      );

      // 4. Return user profile
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthException('Unexpected error: ${e.toString()}'));
    }
  }
}
