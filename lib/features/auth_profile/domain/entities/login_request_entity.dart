import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request_entity.freezed.dart';

/// Login request entity (domain layer)
/// Story 1.2: Login with Email and Password
///
/// Contains credentials for login request.
@freezed
abstract class LoginRequestEntity with _$LoginRequestEntity {
  const factory LoginRequestEntity({
    required String email,
    required String password,
  }) = _LoginRequestEntity;
}
