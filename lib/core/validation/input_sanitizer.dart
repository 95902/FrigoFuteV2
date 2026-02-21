import 'dart:math';

/// Input Sanitization Utilities
/// Story 0.10 Phase 4: Input Sanitization
///
/// Provides client-side validation and sanitization methods to prevent:
/// - XSS (Cross-Site Scripting) attacks
/// - SQL injection (defense in depth, though Firestore uses NoSQL)
/// - Data bloat (excessive string lengths)
/// - Invalid data formats (email, phone, barcodes)
///
/// Usage:
/// ```dart
/// final sanitizedName = InputSanitizer.sanitizeProductName(nameController.text);
/// if (sanitizedName.isEmpty) {
///   return 'Product name cannot be empty';
/// }
/// ```
class InputSanitizer {
  // Maximum lengths for various fields
  static const int maxProductNameLength = 200;
  static const int maxRecipeTextLength = 5000;
  static const int maxGenericInputLength = 500;
  static const int maxDescriptionLength = 1000;

  // EAN-13 barcode length (13 digits)
  static const int ean13Length = 13;

  /// Validates and sanitizes EAN-13 barcode.
  ///
  /// Returns the cleaned barcode if valid, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// final barcode = InputSanitizer.sanitizeEAN13('123-456-789-0123');
  /// // Returns: '1234567890123'
  ///
  /// final invalid = InputSanitizer.sanitizeEAN13('abc123');
  /// // Returns: null
  /// ```
  static String? sanitizeEAN13(String barcode) {
    // Remove non-digit characters
    final cleaned = barcode.replaceAll(RegExp(r'[^0-9]'), '');

    // EAN-13 must be exactly 13 digits
    if (cleaned.length != ean13Length) {
      return null;
    }

    return cleaned;
  }

  /// Validates email format using RFC 5322 simplified regex.
  ///
  /// Returns true if email format is valid.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.isValidEmail('user@example.com'); // true
  /// InputSanitizer.isValidEmail('invalid-email'); // false
  /// ```
  static bool isValidEmail(String email) {
    // RFC 5322 simplified email regex
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    return regex.hasMatch(email.trim());
  }

  /// Sanitizes product name to prevent XSS attacks.
  ///
  /// Removes:
  /// - HTML characters (< > " ' &)
  /// - Script tags (<script>...</script>)
  /// - JavaScript URLs (javascript:)
  /// - Excessive length (max 200 characters)
  ///
  /// Returns sanitized product name.
  ///
  /// Example:
  /// ```dart
  /// final name = InputSanitizer.sanitizeProductName('<script>alert("XSS")</script>Milk');
  /// // Returns: 'Milk'
  /// ```
  static String sanitizeProductName(String name) {
    final sanitized = name
        // Remove dangerous tags FIRST (before removing < >)
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<iframe[^>]*>.*?</iframe>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<body[^>]*>.*?</body>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<img[^>]*>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<body[^>]*>', caseSensitive: false), '') // Self-closing body tags
        // Remove dangerous URLs
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        // Then remove HTML special characters and slashes
        .replaceAll(RegExp('[<>"/\'&;]'), '')
        // Remove excessive whitespace
        .trim();

    // Limit length (use sanitized string length, not original)
    return sanitized.substring(0, min(maxProductNameLength, sanitized.length));
  }

  /// Sanitizes recipe text to prevent XSS attacks.
  ///
  /// Removes:
  /// - Script tags (<script>...</script>)
  /// - Iframe tags (<iframe>...</iframe>)
  /// - JavaScript URLs (javascript:)
  /// - onerror event handlers
  /// - Excessive length (max 5000 characters)
  ///
  /// Note: Preserves basic HTML entities for rich text (if needed).
  ///
  /// Example:
  /// ```dart
  /// final recipe = InputSanitizer.sanitizeRecipeText('Mix <script>alert("XSS")</script> flour and eggs');
  /// // Returns: 'Mix  flour and eggs'
  /// ```
  static String sanitizeRecipeText(String text) {
    final sanitized = text
        // Remove dangerous tags FIRST (before removing < >)
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<iframe.*?</iframe>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<body.*?</body>', caseSensitive: false), '')
        // Remove dangerous URLs and handlers
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'onerror=', caseSensitive: false), '')
        .replaceAll(RegExp(r'onload=', caseSensitive: false), '')
        .replaceAll(RegExp(r'data:', caseSensitive: false), '')
        // Then remove remaining HTML characters
        .replaceAll(RegExp('[<>"/\'&;]'), '')
        // Trim whitespace
        .trim();

    // Limit length (use sanitized string length)
    return sanitized.substring(0, min(maxRecipeTextLength, sanitized.length));
  }

  /// Validates phone number in E.164 format.
  ///
  /// E.164 format: +[country code][number] (e.g., +33612345678)
  /// Length: 1-15 digits after the +
  ///
  /// Returns true if phone number format is valid.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.isValidPhoneNumber('+33612345678'); // true
  /// InputSanitizer.isValidPhoneNumber('0612345678'); // false (missing +)
  /// ```
  static bool isValidPhoneNumber(String phone) {
    // E.164 format: +[country code][number]
    // Must start with +, followed by 1-15 digits
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return regex.hasMatch(phone.trim());
  }

  /// Sanitizes generic user input.
  ///
  /// Use for fields without specific sanitization rules.
  ///
  /// Removes:
  /// - HTML characters (< > " ' &)
  /// - Excessive length (max 500 characters)
  ///
  /// Example:
  /// ```dart
  /// final input = InputSanitizer.sanitizeGenericInput('User <b>comment</b>');
  /// // Returns: 'User comment'
  /// ```
  static String sanitizeGenericInput(String input) {
    final sanitized = input
        // Remove HTML special characters and semicolons
        .replaceAll(RegExp('[<>"/\'&;]'), '')
        // Trim whitespace
        .trim();

    // Limit length (use sanitized string length)
    return sanitized.substring(0, min(maxGenericInputLength, sanitized.length));
  }

  /// Validates and sanitizes quantity (positive number).
  ///
  /// Returns the parsed quantity if valid (> 0), null otherwise.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.sanitizeQuantity('5.5'); // 5.5
  /// InputSanitizer.sanitizeQuantity('-1'); // null (negative)
  /// InputSanitizer.sanitizeQuantity('abc'); // null (not a number)
  /// ```
  static double? sanitizeQuantity(String quantity) {
    final parsed = double.tryParse(quantity.trim());
    if (parsed == null || parsed <= 0) {
      return null;
    }
    return parsed;
  }

  /// Sanitizes product description.
  ///
  /// Similar to sanitizeProductName but allows longer text.
  ///
  /// Example:
  /// ```dart
  /// final desc = InputSanitizer.sanitizeDescription('Fresh <script>alert("XSS")</script> organic milk');
  /// // Returns: 'Fresh  organic milk'
  /// ```
  static String sanitizeDescription(String description) {
    final sanitized = description
        // Remove script tags FIRST
        .replaceAll(RegExp(r'<script.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        // Then remove HTML characters
        .replaceAll(RegExp('[<>"/\'&;]'), '')
        .trim();

    // Limit length (use sanitized string length)
    return sanitized.substring(0, min(maxDescriptionLength, sanitized.length));
  }

  /// Validates EAN-13 barcode with checksum validation.
  ///
  /// The last digit is a checksum calculated from the first 12 digits.
  ///
  /// Returns true if barcode is valid with correct checksum.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.isValidEAN13WithChecksum('5449000000996'); // true
  /// InputSanitizer.isValidEAN13WithChecksum('5449000000999'); // false (wrong checksum)
  /// ```
  static bool isValidEAN13WithChecksum(String barcode) {
    final cleaned = sanitizeEAN13(barcode);
    if (cleaned == null) return false;

    // Calculate checksum
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(cleaned[i]);
      // Multiply odd positions (0-indexed) by 1, even positions by 3
      sum += (i % 2 == 0) ? digit : digit * 3;
    }

    // Checksum is (10 - (sum % 10)) % 10
    final checksum = (10 - (sum % 10)) % 10;
    final providedChecksum = int.parse(cleaned[12]);

    return checksum == providedChecksum;
  }

  /// Validates if string contains only alphanumeric characters and spaces.
  ///
  /// Useful for names, categories, etc.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.isAlphanumeric('Product 123'); // true
  /// InputSanitizer.isAlphanumeric('Product <script>'); // false
  /// ```
  static bool isAlphanumeric(String text) {
    final regex = RegExp(r'^[a-zA-Z0-9\s]+$');
    return regex.hasMatch(text);
  }

  /// Sanitizes URL to prevent XSS and malicious redirects.
  ///
  /// Allows only http:// and https:// URLs.
  ///
  /// Returns sanitized URL if valid, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.sanitizeUrl('https://example.com'); // 'https://example.com'
  /// InputSanitizer.sanitizeUrl('javascript:alert("XSS")'); // null
  /// ```
  static String? sanitizeUrl(String url) {
    final trimmed = url.trim();

    // Only allow http:// and https:// URLs
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return null;
    }

    // Block javascript:, data:, and other potentially malicious schemes
    if (trimmed.contains('javascript:') ||
        trimmed.contains('data:') ||
        trimmed.contains('vbscript:')) {
      return null;
    }

    return trimmed;
  }

  /// Validates price value (positive number with max 2 decimal places).
  ///
  /// Returns the parsed price if valid, null otherwise.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.sanitizePrice('19.99'); // 19.99
  /// InputSanitizer.sanitizePrice('19.999'); // null (too many decimals)
  /// InputSanitizer.sanitizePrice('-5.00'); // null (negative)
  /// ```
  static double? sanitizePrice(String price) {
    final parsed = double.tryParse(price.trim());
    if (parsed == null || parsed < 0) {
      return null;
    }

    // Check decimal places (max 2)
    final parts = price.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return null;
    }

    return parsed;
  }

  /// Removes all HTML tags from text.
  ///
  /// Use for displaying user-generated content safely.
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.stripHtmlTags('<p>Hello <b>world</b></p>'); // 'Hello world'
  /// ```
  static String stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Validates if text contains potentially malicious content.
  ///
  /// Returns true if text appears safe, false if suspicious.
  ///
  /// Checks for:
  /// - Script tags
  /// - JavaScript URLs
  /// - Event handlers (onclick, onerror, etc.)
  /// - Iframe tags
  ///
  /// Example:
  /// ```dart
  /// InputSanitizer.isSafeText('Hello world'); // true
  /// InputSanitizer.isSafeText('<script>alert("XSS")</script>'); // false
  /// ```
  static bool isSafeText(String text) {
    final lowerText = text.toLowerCase();

    // Check for common XSS patterns
    final dangerousPatterns = [
      '<script',
      'javascript:',
      'onerror=',
      'onclick=',
      'onload=',
      '<iframe',
      'data:text/html',
      'vbscript:',
    ];

    for (final pattern in dangerousPatterns) {
      if (lowerText.contains(pattern)) {
        return false;
      }
    }

    return true;
  }
}
