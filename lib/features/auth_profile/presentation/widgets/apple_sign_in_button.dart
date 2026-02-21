import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Apple Sign-In button following Apple Human Interface Guidelines
/// Story 1.4: Login with OAuth Apple Sign-In
///
/// Design requirements (Apple HIG):
/// - Black background (#000000) with white text/logo
/// - Minimum height: 44pt
/// - Text: "Sign in with Apple"
/// - Only displayed on iOS (caller must check Platform.isIOS)
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple
class AppleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AppleSignInButton({
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return SignInWithAppleButton(
      onPressed: onPressed,
      text: 'Sign in with Apple',
      height: 50,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      style: SignInWithAppleButtonStyle.black,
    );
  }
}
