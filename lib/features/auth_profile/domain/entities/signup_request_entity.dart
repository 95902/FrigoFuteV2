import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request_entity.freezed.dart';

/// Signup request entity
/// Story 1.1: Create Account with Email and Password
///
/// Input parameter for SignupUseCase
@freezed
abstract class SignupRequestEntity with _$SignupRequestEntity {
  const factory SignupRequestEntity({
    required String email,
    required String password,
  }) = _SignupRequestEntity;
}
