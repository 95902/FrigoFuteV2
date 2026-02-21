import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/validation/debounced_validator.dart';
import '../../../../core/validation/email_validator.dart';
import '../../../../core/validation/password_validator.dart';
import '../../domain/entities/signup_request_entity.dart';
import '../providers/auth_profile_providers.dart';

/// Signup page - Story 1.1: Create Account with Email and Password
///
/// Features:
/// - Email and password input fields
/// - Confirm password field
/// - Real-time validation with visual indicators
/// - Password strength indicator
/// - Terms & Privacy checkbox
/// - Loading state during signup
/// - Error handling (inline, snackbar)
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // M5: separate debouncers per field to avoid cross-field interference
  final _emailDebouncer = DebouncedValidator();
  final _passwordDebouncer = DebouncedValidator();
  final _confirmDebouncer = DebouncedValidator();

  // H2: proper gesture recognizers for Terms/Privacy links (must be disposed)
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  void _openTerms() => context.go(AppRoutes.termsOfService);
  void _openPrivacy() => context.go(AppRoutes.privacyPolicy);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailDebouncer.dispose();
    _passwordDebouncer.dispose();
    _confirmDebouncer.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  /// Handles signup form submission
  Future<void> _handleSignup() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms agreement
    if (!_agreedToTerms) {
      _showErrorSnackBar('Please accept the Terms & Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call signup use case
      final signupUseCase = ref.read(signupUseCaseProvider);
      final request = SignupRequestEntity(
        email: EmailValidator.normalize(_emailController.text),
        password: _passwordController.text,
      );

      final result = await signupUseCase.call(request);

      result.fold(
        // Error case
        (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            _showErrorMessage(error);
          }
        },
        // Success case — H1: auto-navigate directly, no blocking dialog
        (user) {
          if (mounted) {
            setState(() => _isLoading = false);
            context.go(AppRoutes.onboarding);
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

  /// Shows contextual error message — M1: Login action on email-already-in-use,
  /// M2: Retry action on network error, generic Dismiss for others.
  void _showErrorMessage(AuthException error) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    SnackBarAction action;
    switch (error.code) {
      case 'email-already-in-use':
        // M1: offer direct navigation to login screen
        action = SnackBarAction(
          label: 'Login',
          textColor: Colors.white,
          onPressed: () => context.go(AppRoutes.login),
        );
      case 'network-request-failed':
        // M2: offer retry
        action = SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _handleSignup,
        );
      default:
        action = SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: messenger.hideCurrentSnackBar,
        );
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Generic error snackbar (non-auth errors from catch block)
  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'At least 8 characters',
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
                  validator: (value) =>
                      PasswordValidator.validate(value ?? ''),
                  onChanged: (value) {
                    _passwordDebouncer.run(() {
                      setState(() {}); // Rebuild for strength indicator
                      _formKey.currentState?.validate();
                    });
                  },
                ),

                // Password strength indicator
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ),
                ],

                const SizedBox(height: 16),

                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _confirmDebouncer.run(() {
                      _formKey.currentState?.validate();
                    });
                  },
                  onFieldSubmitted: (_) => _handleSignup(),
                ),

                const SizedBox(height: 24),

                // Terms & Privacy checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() => _agreedToTerms = value ?? false);
                            },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: GestureDetector(
                          // Tapping the label text toggles the checkbox
                          onTap: _isLoading
                              ? null
                              : () => setState(
                                    () => _agreedToTerms = !_agreedToTerms,
                                  ),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                // H2: "Terms of Service" opens the actual screen
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _isLoading
                                      ? null
                                      : _termsRecognizer,
                                ),
                                const TextSpan(text: ' and '),
                                // H2: "Privacy Policy" opens the actual screen
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _isLoading
                                      ? null
                                      : _privacyRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Create Account button
                FilledButton(
                  onPressed: _isLoading ? null : _handleSignup,
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
                      : const Text('Create Account'),
                ),

                const SizedBox(height: 16),

                // Already have account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      child: const Text('Login'),
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

/// Password strength indicator widget
class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const _PasswordStrengthIndicator({required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = PasswordValidator.calculateStrength(password);
    final label = PasswordValidator.getStrengthLabel(strength);

    Color color;
    if (strength < 0.3) {
      color = Colors.red;
    } else if (strength < 0.6) {
      color = Colors.orange;
    } else if (strength < 0.8) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: strength,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Use at least 8 characters with a mix of letters, numbers & symbols',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
