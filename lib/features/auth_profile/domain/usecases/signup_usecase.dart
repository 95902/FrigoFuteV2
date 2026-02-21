import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/validation/email_validator.dart';
import '../../../../core/validation/password_validator.dart';
import '../entities/signup_request_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Signup use case (domain layer)
/// Story 1.1: Create Account with Email and Password
///
/// Validates input and creates a new user account.
/// Returns Either<AuthException, UserEntity>.
class SignupUseCase {
  final AuthRepository _repository;

  SignupUseCase(this._repository);

  /// Executes the signup use case.
  ///
  /// Flow:
  /// 1. Validate email format (client-side)
  /// 2. Validate password strength (client-side)
  /// 3. Call repository to create account
  /// 4. Return user entity or error
  ///
  /// Returns:
  /// - Left(AuthException): Validation failed or signup failed
  /// - Right(UserEntity): Signup successful
  Future<Either<AuthException, UserEntity>> call(
    SignupRequestEntity request,
  ) async {
    try {
      // 1. Validate email
      final emailError = EmailValidator.validate(request.email);
      if (emailError != null) {
        return Left(AuthException(emailError, code: 'invalid-email'));
      }

      // 2. Validate password
      final passwordError = PasswordValidator.validate(request.password);
      if (passwordError != null) {
        return Left(AuthException(passwordError, code: 'weak-password'));
      }

      // 3. Create Firebase Auth user (via repository)
      final user = await _repository.signUpWithEmail(
        request.email,
        request.password,
      );

      // 4. Return user entity
      return Right(user);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AuthException('Unexpected error: ${e.toString()}'),
      );
    }
  }
}
