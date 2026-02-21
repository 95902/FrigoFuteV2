import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_state_provider.freezed.dart';

/// Signup state for UI
/// Story 1.1: Create Account with Email and Password
@freezed
abstract class SignupState with _$SignupState {
  const factory SignupState({
    @Default(false) bool isLoading,
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default(false) bool agreedToTerms,
    String? errorMessage,
  }) = _SignupState;
}

/// Signup state notifier
/// Story 1.1: Create Account with Email and Password
///
/// Manages signup form state (optional - currently using StatefulWidget)
class SignupStateNotifier extends StateNotifier<SignupState> {
  SignupStateNotifier() : super(const SignupState());

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword);
  }

  void setAgreedToTerms(bool agreed) {
    state = state.copyWith(agreedToTerms: agreed);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  void reset() {
    state = const SignupState();
  }
}

/// Signup state provider
/// Story 1.1: Create Account with Email and Password
final signupStateProvider =
    StateNotifierProvider<SignupStateNotifier, SignupState>((ref) {
  return SignupStateNotifier();
});
