import 'package:flutter/material.dart';

/// Google Sign-In button widget following Material Design 3 guidelines.
///
/// Story 1.3: Login with OAuth (Google Sign-In)
///
/// Features:
/// - Google logo with proper spacing
/// - Minimum 56dp touch target (accessibility)
/// - Loading state with spinner
/// - Disabled state when loading
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56, // Material Design 3: Minimum 56dp touch target
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          shadowColor: Colors.black26,
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              )
            else
              // TODO(M2): Replace with official Google "G" logo asset.
              // Icons.g_mobiledata is a Material mobile-data icon, NOT the
              // Google brand logo. Google branding guidelines require the
              // official SVG from https://developers.google.com/identity/branding-guidelines
              // Add it as assets/icons/google_logo.svg and render with flutter_svg:
              //   Image.asset('assets/icons/google_logo.png', width: 24, height: 24)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Colors.blue.shade700,
                ),
              ),
            const SizedBox(width: 12), // Material Design 3: 12dp spacing
            Text(
              isLoading ? 'Signing in...' : 'Continue with Google',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
