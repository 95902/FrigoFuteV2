import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/validation/email_validator.dart';
import '../providers/auth_profile_providers.dart';

/// Forgot Password page - Story 1.2: Login with Email and Password
///
/// Features:
/// - Email input field
/// - Send password reset email
/// - Success state with confirmation message
/// - Error handling (snackbar)
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _emailSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles password reset request
  Future<void> _handleResetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call password reset use case
      final passwordResetUseCase = ref.read(passwordResetUseCaseProvider);
      final email = EmailValidator.normalize(_emailController.text);

      final result = await passwordResetUseCase.call(email);

      result.fold(
        // Error case
        (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(error.message);
          }
        },
        // Success case
        (_) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _emailSent = true;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Shows error message in snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  /// Builds the form state (email input + send button)
  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Header
          Text(
            'Forgot your password?',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'your.email@example.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) => EmailValidator.validate(value ?? ''),
            onFieldSubmitted: (_) => _handleResetPassword(),
          ),

          const SizedBox(height: 24),

          // Send reset email button
          FilledButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Send Reset Email'),
          ),

          const SizedBox(height: 16),

          // Back to login link
          TextButton(
            onPressed: _isLoading ? null : () => context.go(AppRoutes.login),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }

  /// Builds the success state (email sent confirmation)
  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success icon
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: 24),

          // Success title
          Text(
            'Check your email',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Success message
          Text(
            'We\'ve sent a password reset link to:',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Email address
          Text(
            _emailController.text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Instructions
          Text(
            'Click the link in the email to reset your password. '
            'If you don\'t see it, check your spam folder.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Back to login button
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            ),
            child: const Text('Back to Login'),
          ),
        ],
      ),
    );
  }
}
