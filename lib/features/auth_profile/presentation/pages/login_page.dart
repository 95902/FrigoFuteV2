import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/validation/debounced_validator.dart';
import '../../../../core/validation/email_validator.dart';
import '../../domain/entities/login_request_entity.dart';
import '../providers/auth_profile_providers.dart';
import '../widgets/apple_sign_in_button.dart';
import '../widgets/google_sign_in_button.dart';

/// Login page - Story 1.2: Login with Email and Password
///
/// Features:
/// - Email and password input fields
/// - Real-time validation with visual indicators
/// - Loading state during login
/// - Error handling (snackbar)
/// - "Forgot Password?" link
/// - Navigate to signup page
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // M1: separate debouncers per field to avoid cross-field interference
  final _emailDebouncer = DebouncedValidator();
  final _passwordDebouncer = DebouncedValidator();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleSigningIn = false;
  bool _isAppleSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailDebouncer.dispose();
    _passwordDebouncer.dispose();
    super.dispose();
  }

  /// Handles login form submission
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call login use case
      final loginUseCase = ref.read(loginUseCaseProvider);
      final request = LoginRequestEntity(
        email: EmailValidator.normalize(_emailController.text),
        password: _passwordController.text,
      );

      final result = await loginUseCase.call(request);

      result.fold(
        // Error case
        (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            // H2: show dialog OR snackbar, never both simultaneously
            if (error.code == 'too-many-requests') {
              _showRateLimitDialog();
            } else {
              _showErrorMessage(error);
            }
          }
        },
        // Success case — navigate directly, no noise snackbar before immediate navigation
        (user) {
          if (mounted) {
            setState(() => _isLoading = false);
            if (user.profileType.isEmpty) {
              context.go(AppRoutes.onboarding);
            } else {
              context.go(AppRoutes.dashboard);
            }
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

  /// Handles Google Sign-In
  /// Story 1.3: Login with OAuth (Google Sign-In)
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSigningIn = true);

    try {
      // Call Google Sign-In use case
      final loginWithGoogleUseCase = ref.read(loginWithGoogleUseCaseProvider);
      final result = await loginWithGoogleUseCase.call();

      result.fold(
        // Error case
        (error) {
          if (mounted) {
            setState(() => _isGoogleSigningIn = false);
            _showErrorSnackBar(error.message);
          }
        },
        // Success case
        (user) {
          if (mounted) {
            setState(() => _isGoogleSigningIn = false);

            if (user == null) {
              // User cancelled - no error message needed
              return;
            }

            // Navigate directly, no noise snackbar before immediate navigation
            if (user.profileType.isEmpty) {
              context.go(AppRoutes.onboarding);
            } else {
              context.go(AppRoutes.dashboard);
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleSigningIn = false);
        _showErrorSnackBar('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Handles Apple Sign-In
  /// Story 1.4: Login with OAuth Apple Sign-In
  Future<void> _handleAppleSignIn() async {
    setState(() => _isAppleSigningIn = true);

    try {
      final loginWithAppleUseCase = ref.read(loginWithAppleUseCaseProvider);
      final result = await loginWithAppleUseCase.call();

      result.fold(
        (error) {
          if (mounted) {
            setState(() => _isAppleSigningIn = false);
            _showErrorMessage(error, onRetry: _handleAppleSignIn); // M2: AC7 Retry for network errors
          }
        },
        (user) {
          if (mounted) {
            setState(() => _isAppleSigningIn = false);

            if (user == null) {
              // AC6: Show neutral cancellation message
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(
                  content: Text('Sign-in cancelled'),
                  behavior: SnackBarBehavior.floating,
                ));
              return;
            }

            // AC2/AC3: Show contextual welcome message before navigation
            if (user.profileType.isEmpty) {
              _showSuccessSnackBar('Welcome! Let\'s complete your profile');
              context.go(AppRoutes.onboarding);
            } else {
              _showSuccessSnackBar('Welcome back!');
              context.go(AppRoutes.dashboard);
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isAppleSigningIn = false);
        _showErrorSnackBar('Unexpected error: ${e.toString()}');
      }
    }
  }

  /// Generic error snackbar (for unexpected catch-block errors)
  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: messenger.hideCurrentSnackBar,
        ),
      ),
    );
  }

  /// Contextual error message — M4: Retry action for network errors (AC7/AC9)
  ///
  /// [onRetry] defaults to [_handleLogin] for email/password. OAuth callers
  /// must pass their own retry callback (e.g. _handleAppleSignIn).
  void _showErrorMessage(AuthException error, {VoidCallback? onRetry}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final action = error.code == 'network-request-failed'
        ? SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: onRetry ?? _handleLogin,
          )
        : SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: messenger.hideCurrentSnackBar,
          );

    messenger.showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Shows rate limit dialog
  void _showRateLimitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Too Many Attempts'),
        content: const Text(
          'You have exceeded the maximum number of login attempts. '
          'Please wait 5 minutes before trying again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Disable form for 5 minutes
              setState(() => _isLoading = true);
              Future.delayed(const Duration(minutes: 5), () {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Success snackbar for OAuth sign-in welcome messages (AC2, AC3)
  void _showSuccessSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Welcome header
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to access your food inventory',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'your.email@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => EmailValidator.validate(value ?? ''),
                  onChanged: (value) {
                    _emailDebouncer.run(() {
                      _formKey.currentState?.validate();
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _passwordDebouncer.run(() {
                      _formKey.currentState?.validate();
                    });
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: 24),

                // Login button
                FilledButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: 16),

                // Forgot password link
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => context.push(AppRoutes.forgotPassword),
                    child: const Text('Forgot Password?'),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with "Or" text
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign-In button (Story 1.3)
                GoogleSignInButton(
                  onPressed: _handleGoogleSignIn,
                  isLoading: _isGoogleSigningIn,
                ),

                // Apple Sign-In button — iOS only (Story 1.4)
                if (Platform.isIOS) ...[
                  const SizedBox(height: 12),
                  AppleSignInButton(
                    onPressed: _handleAppleSignIn,
                    isLoading: _isAppleSigningIn,
                  ),
                ],

                const SizedBox(height: 16),

                // Terms disclaimer
                Text(
                  'By signing in, you accept our Terms of Service and Privacy Policy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.push(AppRoutes.register),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
