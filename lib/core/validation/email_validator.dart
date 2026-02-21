/// Email validation utilities for user authentication
/// Story 1.1: Create Account with Email and Password
///
/// Validates email format and provides normalization helpers
class EmailValidator {
  /// Email regex pattern
  /// Format: user@domain.extension
  /// Supports: dots, plus signs, hyphens in local part
  /// Minimum: 2-char TLD
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  );

  /// Validates email format.
  ///
  /// Returns error message if invalid, null if valid.
  ///
  /// Examples:
  /// ```dart
  /// EmailValidator.validate('user@example.com'); // null (valid)
  /// EmailValidator.validate('invalid'); // 'Please enter a valid email address'
  /// ```
  static String? validate(String email) {
    final trimmed = email.trim();

    if (trimmed.isEmpty) {
      return 'Email is required';
    }

    // Check for consecutive dots (invalid per RFC 5322)
    if (trimmed.contains('..')) {
      return 'Please enter a valid email address';
    }

    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Normalizes email (trim + lowercase).
  ///
  /// Firebase Auth stores emails in lowercase, so we normalize
  /// to ensure consistent matching.
  ///
  /// Example:
  /// ```dart
  /// EmailValidator.normalize('User@Example.COM'); // 'user@example.com'
  /// ```
  static String normalize(String email) {
    return email.trim().toLowerCase();
  }
}
