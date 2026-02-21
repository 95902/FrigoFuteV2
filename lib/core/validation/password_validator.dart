/// Password validation utilities for user authentication
/// Story 1.1: Create Account with Email and Password
///
/// Validates password strength and provides strength calculation helpers
class PasswordValidator {
  /// Minimum password length (stricter than Firebase default of 6)
  static const int minLength = 8;

  /// Maximum password length (Firebase limit)
  static const int maxLength = 128;

  /// Validates password strength.
  ///
  /// Returns error message if invalid, null if valid.
  ///
  /// Requirements:
  /// - Minimum 8 characters
  /// - Maximum 128 characters
  ///
  /// Examples:
  /// ```dart
  /// PasswordValidator.validate('password123'); // null (valid)
  /// PasswordValidator.validate('123'); // 'Password must be at least 8 characters'
  /// ```
  static String? validate(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    if (password.length > maxLength) {
      return 'Password must be less than $maxLength characters';
    }

    // Optional: Add strength check here if needed
    // final strength = calculateStrength(password);
    // if (strength < 0.5) return 'Password is too weak';

    return null; // Valid
  }

  /// Calculates password strength (0.0 to 1.0).
  ///
  /// Factors considered:
  /// - Length (8+ chars: +0.2, 12+ chars: +0.2)
  /// - Lowercase letters (+0.15)
  /// - Uppercase letters (+0.15)
  /// - Numbers (+0.15)
  /// - Special characters (+0.15)
  ///
  /// Maximum score: 1.0 (Strong)
  ///
  /// Example:
  /// ```dart
  /// PasswordValidator.calculateStrength('password'); // ~0.35 (Weak-Fair)
  /// PasswordValidator.calculateStrength('Password1!'); // ~0.8 (Strong)
  /// ```
  static double calculateStrength(String password) {
    double strength = 0.0;

    // Length score (0.4 max)
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;

    // Character variety score (0.6 max)
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15; // Lowercase
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15; // Uppercase
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15; // Numbers
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      strength += 0.15; // Special chars
    }

    return strength.clamp(0.0, 1.0);
  }

  /// Returns password strength label.
  ///
  /// - < 0.3: "Weak"
  /// - 0.3-0.6: "Fair"
  /// - 0.6-0.8: "Good"
  /// - >= 0.8: "Strong"
  ///
  /// Example:
  /// ```dart
  /// final strength = PasswordValidator.calculateStrength('Password1!');
  /// final label = PasswordValidator.getStrengthLabel(strength); // "Strong"
  /// ```
  static String getStrengthLabel(double strength) {
    if (strength < 0.3) return 'Weak';
    if (strength < 0.6) return 'Fair';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }
}
