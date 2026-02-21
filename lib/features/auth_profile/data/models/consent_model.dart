import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_model.freezed.dart';
part 'consent_model.g.dart';

/// Consent model for RGPD/GDPR compliance
/// Story 1.1: Create Account with Email and Password
///
/// Tracks user consent for various data processing activities
@freezed
abstract class ConsentModel with _$ConsentModel {
  const ConsentModel._();

  const factory ConsentModel({
    required bool termsOfService,
    required bool privacyPolicy,
    @Default(false) bool healthData,
    @Default(false) bool analytics,
  }) = _ConsentModel;

  factory ConsentModel.fromJson(Map<String, dynamic> json) =>
      _$ConsentModelFromJson(json);
}
