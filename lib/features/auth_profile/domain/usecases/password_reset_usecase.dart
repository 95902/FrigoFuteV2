import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/validation/email_validator.dart';
import '../repositories/auth_repository.dart';

/// Password reset use case (domain layer)
/// Story 1.2: Login with Email and Password
///
/// Sends password reset email to user via Firebase Auth.
class PasswordResetUseCase {
  final AuthRepository _repository;

  PasswordResetUseCase(this._repository);

  /// Sends password reset email to user.
  ///
  /// Flow:
  /// 1. Validate email format
  /// 2. Call Firebase Auth sendPasswordResetEmail
  /// 3. Firebase sends email with reset link
  ///
  /// Note: Firebase doesn't reveal if email exists (privacy protection).
  /// The email is sent if the account exists, silently ignored otherwise.
  ///
  /// Returns [Right(void)] on success.
  /// Returns [Left(AuthException)] on failure (e.g., invalid email format, network error).
  Future<Either<AuthException, void>> call(String email) async {
    try {
      // 1. Validate email format
      final emailError = EmailValidator.validate(email);
      if (emailError != null) {
        return Left(AuthException(emailError, code: 'invalid-email'));
      }

      // 2. Send password reset email via Firebase Auth
      await _repository.sendPasswordResetEmail(email);

      // 3. Return success
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AuthException('Unexpected error: ${e.toString()}'));
    }
  }
}
