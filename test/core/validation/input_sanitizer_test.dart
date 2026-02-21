import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/validation/input_sanitizer.dart';

/// Unit tests for InputSanitizer
/// Story 0.10 Phase 4: Input Sanitization
///
/// Tests all validation and sanitization methods with:
/// - Happy path tests
/// - Edge cases (empty, null-like, extreme values)
/// - XSS attack vectors
/// - SQL injection attempts (defense in depth)
void main() {
  group('InputSanitizer', () {
    group('sanitizeEAN13()', () {
      test('should validate correct EAN-13 barcode', () {
        expect(InputSanitizer.sanitizeEAN13('1234567890123'), '1234567890123');
      });

      test('should remove non-digit characters', () {
        expect(InputSanitizer.sanitizeEAN13('123-456-789-0123'), '1234567890123');
        expect(InputSanitizer.sanitizeEAN13('123 456 789 0123'), '1234567890123');
        expect(InputSanitizer.sanitizeEAN13('123.456.789.0123'), '1234567890123');
      });

      test('should reject barcode with wrong length', () {
        expect(InputSanitizer.sanitizeEAN13('123'), null); // Too short
        expect(InputSanitizer.sanitizeEAN13('12345678901234'), null); // Too long
        expect(InputSanitizer.sanitizeEAN13(''), null); // Empty
      });

      test('should reject barcode with letters', () {
        expect(InputSanitizer.sanitizeEAN13('abc1234567890'), null);
        expect(InputSanitizer.sanitizeEAN13('123456789012a'), null);
      });

      test('should handle real EAN-13 barcodes', () {
        // Real Coca-Cola EAN-13
        expect(InputSanitizer.sanitizeEAN13('5449000000996'), '5449000000996');
      });
    });

    group('isValidEmail()', () {
      test('should validate correct email formats', () {
        expect(InputSanitizer.isValidEmail('user@example.com'), true);
        expect(InputSanitizer.isValidEmail('test.user@example.com'), true);
        expect(InputSanitizer.isValidEmail('user+tag@example.com'), true);
        expect(InputSanitizer.isValidEmail('user_123@example.co.uk'), true);
      });

      test('should reject invalid email formats', () {
        expect(InputSanitizer.isValidEmail('invalid-email'), false);
        expect(InputSanitizer.isValidEmail('user@'), false);
        expect(InputSanitizer.isValidEmail('@example.com'), false);
        expect(InputSanitizer.isValidEmail('user@.com'), false);
        expect(InputSanitizer.isValidEmail(''), false);
      });

      test('should handle edge cases', () {
        expect(InputSanitizer.isValidEmail('user@sub.example.com'), true); // Subdomain
        expect(InputSanitizer.isValidEmail('user@example'), false); // No TLD
        expect(InputSanitizer.isValidEmail('user space@example.com'), false); // Space
      });
    });

    group('sanitizeProductName()', () {
      test('should return clean product name', () {
        expect(InputSanitizer.sanitizeProductName('Fresh Milk'), 'Fresh Milk');
        expect(InputSanitizer.sanitizeProductName('Coca-Cola 1.5L'), 'Coca-Cola 1.5L');
      });

      test('should remove XSS attack vectors', () {
        // Script tag injection
        expect(
          InputSanitizer.sanitizeProductName('<script>alert("XSS")</script>Milk'),
          'Milk',
        );

        // JavaScript URL (javascript: removed, then quotes removed)
        expect(
          InputSanitizer.sanitizeProductName('javascript:alert("XSS")'),
          'alert(XSS)',
        );

        // HTML characters
        expect(
          InputSanitizer.sanitizeProductName('Product<Name>'),
          'ProductName',
        );

        // Mixed attack
        expect(
          InputSanitizer.sanitizeProductName('<script>javascript:alert("XSS")</script>Product'),
          'Product',
        );
      });

      test('should enforce maximum length', () {
        final longName = 'A' * 300;
        final sanitized = InputSanitizer.sanitizeProductName(longName);
        expect(sanitized.length, 200); // Max length
      });

      test('should trim whitespace', () {
        expect(InputSanitizer.sanitizeProductName('  Milk  '), 'Milk');
        expect(InputSanitizer.sanitizeProductName('\nMilk\n'), 'Milk');
      });

      test('should handle empty input', () {
        expect(InputSanitizer.sanitizeProductName(''), '');
        expect(InputSanitizer.sanitizeProductName('   '), '');
      });
    });

    group('sanitizeRecipeText()', () {
      test('should return clean recipe text', () {
        expect(
          InputSanitizer.sanitizeRecipeText('Mix flour and eggs'),
          'Mix flour and eggs',
        );
      });

      test('should remove XSS attack vectors', () {
        // Script tags
        expect(
          InputSanitizer.sanitizeRecipeText('Mix <script>alert("XSS")</script> flour'),
          'Mix  flour',
        );

        // Iframe tags
        expect(
          InputSanitizer.sanitizeRecipeText('Mix <iframe src="evil.com"></iframe> flour'),
          'Mix  flour',
        );

        // JavaScript URLs
        expect(
          InputSanitizer.sanitizeRecipeText('Click javascript:alert("XSS")'),
          'Click alert(XSS)',
        );

        // onerror event handler (onerror= removed, leaving a space)
        expect(
          InputSanitizer.sanitizeRecipeText('<img src=x onerror=alert("XSS")>'),
          'img src=x alert(XSS)',
        );

        // Data URLs (data: removed, script tag AND content removed for safety)
        expect(
          InputSanitizer.sanitizeRecipeText('Click data:text/html,<script>alert("XSS")</script>'),
          'Click texthtml,',
        );
      });

      test('should enforce maximum length', () {
        final longText = 'A' * 6000;
        final sanitized = InputSanitizer.sanitizeRecipeText(longText);
        expect(sanitized.length, 5000); // Max length
      });

      test('should handle multiple attack vectors', () {
        const malicious = '<script>alert(1)</script><iframe src="evil"></iframe>javascript:void(0)';
        final sanitized = InputSanitizer.sanitizeRecipeText(malicious);
        expect(sanitized, 'void(0)');
      });
    });

    group('isValidPhoneNumber()', () {
      test('should validate E.164 format phone numbers', () {
        expect(InputSanitizer.isValidPhoneNumber('+33612345678'), true); // France
        expect(InputSanitizer.isValidPhoneNumber('+14155552671'), true); // USA
        expect(InputSanitizer.isValidPhoneNumber('+442071838750'), true); // UK
      });

      test('should reject invalid phone numbers', () {
        expect(InputSanitizer.isValidPhoneNumber('0612345678'), false); // No +
        expect(InputSanitizer.isValidPhoneNumber('+1'), false); // Too short
        expect(InputSanitizer.isValidPhoneNumber('+12345678901234567'), false); // Too long
        expect(InputSanitizer.isValidPhoneNumber('abc123'), false); // Letters
        expect(InputSanitizer.isValidPhoneNumber(''), false); // Empty
      });

      test('should handle edge cases', () {
        expect(InputSanitizer.isValidPhoneNumber('+1234567890123'), true); // Max length
        expect(InputSanitizer.isValidPhoneNumber('+12'), true); // Min length
      });
    });

    group('sanitizeGenericInput()', () {
      test('should sanitize generic user input', () {
        expect(InputSanitizer.sanitizeGenericInput('Normal text'), 'Normal text');
      });

      test('should remove HTML characters', () {
        expect(InputSanitizer.sanitizeGenericInput('Text with <html>'), 'Text with html');
        expect(InputSanitizer.sanitizeGenericInput('Quoted "text"'), 'Quoted text');
      });

      test('should enforce maximum length', () {
        final longText = 'A' * 600;
        final sanitized = InputSanitizer.sanitizeGenericInput(longText);
        expect(sanitized.length, 500); // Max length
      });

      test('should trim whitespace', () {
        expect(InputSanitizer.sanitizeGenericInput('  text  '), 'text');
      });
    });

    group('sanitizeQuantity()', () {
      test('should parse valid quantities', () {
        expect(InputSanitizer.sanitizeQuantity('5'), 5.0);
        expect(InputSanitizer.sanitizeQuantity('5.5'), 5.5);
        expect(InputSanitizer.sanitizeQuantity('0.1'), 0.1);
        expect(InputSanitizer.sanitizeQuantity('100.99'), 100.99);
      });

      test('should reject invalid quantities', () {
        expect(InputSanitizer.sanitizeQuantity('-1'), null); // Negative
        expect(InputSanitizer.sanitizeQuantity('0'), null); // Zero
        expect(InputSanitizer.sanitizeQuantity('abc'), null); // Not a number
        expect(InputSanitizer.sanitizeQuantity(''), null); // Empty
      });

      test('should handle edge cases', () {
        expect(InputSanitizer.sanitizeQuantity('0.0001'), 0.0001); // Very small
        expect(InputSanitizer.sanitizeQuantity('999999'), 999999.0); // Very large
      });
    });

    group('sanitizeDescription()', () {
      test('should sanitize product descriptions', () {
        expect(
          InputSanitizer.sanitizeDescription('Fresh organic milk'),
          'Fresh organic milk',
        );
      });

      test('should remove XSS vectors', () {
        expect(
          InputSanitizer.sanitizeDescription('Fresh <script>alert("XSS")</script> milk'),
          'Fresh  milk',
        );
      });

      test('should enforce maximum length', () {
        final longDesc = 'A' * 1500;
        final sanitized = InputSanitizer.sanitizeDescription(longDesc);
        expect(sanitized.length, 1000); // Max length
      });
    });

    group('isValidEAN13WithChecksum()', () {
      test('should validate EAN-13 with correct checksum', () {
        // Real EAN-13 barcodes with valid checksums
        expect(InputSanitizer.isValidEAN13WithChecksum('5449000000996'), true); // Coca-Cola
        expect(InputSanitizer.isValidEAN13WithChecksum('3017620422003'), true); // Nutella
      });

      test('should reject EAN-13 with incorrect checksum', () {
        expect(InputSanitizer.isValidEAN13WithChecksum('5449000000999'), false); // Wrong checksum
        expect(InputSanitizer.isValidEAN13WithChecksum('1234567890123'), false); // Random digits
      });

      test('should reject invalid formats', () {
        expect(InputSanitizer.isValidEAN13WithChecksum('123'), false); // Too short
        expect(InputSanitizer.isValidEAN13WithChecksum('abc'), false); // Letters
      });
    });

    group('isAlphanumeric()', () {
      test('should validate alphanumeric text', () {
        expect(InputSanitizer.isAlphanumeric('Product123'), true);
        expect(InputSanitizer.isAlphanumeric('Product Name 123'), true); // Spaces allowed
        expect(InputSanitizer.isAlphanumeric('ABC xyz 123'), true);
      });

      test('should reject non-alphanumeric text', () {
        expect(InputSanitizer.isAlphanumeric('Product<script>'), false);
        expect(InputSanitizer.isAlphanumeric('Product@123'), false);
        expect(InputSanitizer.isAlphanumeric('Product-Name'), false); // Hyphens not allowed
      });
    });

    group('sanitizeUrl()', () {
      test('should validate safe URLs', () {
        expect(
          InputSanitizer.sanitizeUrl('https://example.com'),
          'https://example.com',
        );
        expect(
          InputSanitizer.sanitizeUrl('http://example.com/path'),
          'http://example.com/path',
        );
      });

      test('should reject malicious URLs', () {
        expect(InputSanitizer.sanitizeUrl('javascript:alert("XSS")'), null);
        expect(InputSanitizer.sanitizeUrl('data:text/html,<script>'), null);
        expect(InputSanitizer.sanitizeUrl('vbscript:msgbox("XSS")'), null);
      });

      test('should reject non-HTTP URLs', () {
        expect(InputSanitizer.sanitizeUrl('ftp://example.com'), null);
        expect(InputSanitizer.sanitizeUrl('file:///etc/passwd'), null);
      });
    });

    group('sanitizePrice()', () {
      test('should validate correct prices', () {
        expect(InputSanitizer.sanitizePrice('19.99'), 19.99);
        expect(InputSanitizer.sanitizePrice('5.5'), 5.5);
        expect(InputSanitizer.sanitizePrice('100'), 100.0);
        expect(InputSanitizer.sanitizePrice('0.99'), 0.99);
      });

      test('should reject invalid prices', () {
        expect(InputSanitizer.sanitizePrice('-5.00'), null); // Negative
        expect(InputSanitizer.sanitizePrice('19.999'), null); // Too many decimals
        expect(InputSanitizer.sanitizePrice('abc'), null); // Not a number
      });

      test('should handle edge cases', () {
        expect(InputSanitizer.sanitizePrice('0'), 0.0); // Free item
        expect(InputSanitizer.sanitizePrice('999999.99'), 999999.99); // Expensive
      });
    });

    group('stripHtmlTags()', () {
      test('should remove all HTML tags', () {
        expect(
          InputSanitizer.stripHtmlTags('<p>Hello <b>world</b></p>'),
          'Hello world',
        );
        expect(
          InputSanitizer.stripHtmlTags('<div><span>Text</span></div>'),
          'Text',
        );
      });

      test('should handle malformed HTML', () {
        expect(InputSanitizer.stripHtmlTags('<p>Text<b>'), 'Text');
        expect(InputSanitizer.stripHtmlTags('Text</p>'), 'Text');
      });

      test('should handle plain text', () {
        expect(InputSanitizer.stripHtmlTags('Plain text'), 'Plain text');
      });
    });

    group('isSafeText()', () {
      test('should recognize safe text', () {
        expect(InputSanitizer.isSafeText('Hello world'), true);
        expect(InputSanitizer.isSafeText('Product description'), true);
        expect(InputSanitizer.isSafeText('Price: 19.99'), true);
      });

      test('should detect XSS attack vectors', () {
        expect(InputSanitizer.isSafeText('<script>alert("XSS")</script>'), false);
        expect(InputSanitizer.isSafeText('javascript:alert("XSS")'), false);
        expect(InputSanitizer.isSafeText('<img onerror=alert("XSS")>'), false);
        expect(InputSanitizer.isSafeText('<iframe src="evil.com">'), false);
        expect(InputSanitizer.isSafeText('data:text/html,<script>'), false);
      });

      test('should detect event handlers', () {
        expect(InputSanitizer.isSafeText('onclick=alert(1)'), false);
        expect(InputSanitizer.isSafeText('onload=steal()'), false);
        expect(InputSanitizer.isSafeText('onerror=evil()'), false);
      });

      test('should be case-insensitive', () {
        expect(InputSanitizer.isSafeText('<SCRIPT>alert(1)</SCRIPT>'), false);
        expect(InputSanitizer.isSafeText('JAVASCRIPT:alert(1)'), false);
      });
    });

    group('SQL Injection Defense (Defense in Depth)', () {
      test('sanitizeProductName should remove SQL injection attempts', () {
        // Even though Firestore uses NoSQL, we test defense in depth
        // Quotes and semicolons are removed
        expect(
          InputSanitizer.sanitizeProductName("'; DROP TABLE users; --"),
          'DROP TABLE users --',
        );

        expect(
          InputSanitizer.sanitizeProductName("1' OR '1'='1"),
          '1 OR 1=1',
        );
      });

      test('sanitizeGenericInput should remove dangerous characters', () {
        expect(
          InputSanitizer.sanitizeGenericInput("admin'--"),
          'admin--',
        );
      });
    });

    group('Edge Cases and Extreme Inputs', () {
      test('should handle empty strings', () {
        expect(InputSanitizer.sanitizeProductName(''), '');
        expect(InputSanitizer.sanitizeGenericInput(''), '');
        expect(InputSanitizer.isValidEmail(''), false);
        expect(InputSanitizer.sanitizeEAN13(''), null);
      });

      test('should handle whitespace-only strings', () {
        expect(InputSanitizer.sanitizeProductName('   '), '');
        expect(InputSanitizer.sanitizeGenericInput('   '), '');
      });

      test('should handle very long strings', () {
        final veryLong = 'A' * 10000;
        final sanitized = InputSanitizer.sanitizeProductName(veryLong);
        expect(sanitized.length, 200); // Truncated to max
      });

      test('should handle special Unicode characters', () {
        expect(InputSanitizer.sanitizeProductName('Café ☕'), 'Café ☕');
        expect(InputSanitizer.sanitizeProductName('北京 🇨🇳'), '北京 🇨🇳');
      });

      test('should handle multiple XSS vectors in one string', () {
        const multiAttack = '<script>alert(1)</script><iframe></iframe>javascript:void(0)';
        final sanitized = InputSanitizer.sanitizeProductName(multiAttack);
        // <script>alert(1)</script> removed -> <iframe></iframe>javascript:void(0)
        // <iframe></iframe> removed -> javascript:void(0)
        // javascript: removed -> void(0)
        expect(sanitized, 'void(0)');
      });
    });

    group('Real-World Attack Vectors (OWASP Top 10)', () {
      test('should block stored XSS attacks', () {
        final attacks = [
          '<script>alert(document.cookie)</script>',
          '<img src=x onerror=alert(1)>',
          '<svg onload=alert(1)>',
          '"><script>alert(1)</script>',
          '<iframe src=javascript:alert(1)>',
        ];

        for (final attack in attacks) {
          final sanitized = InputSanitizer.sanitizeProductName(attack);
          expect(sanitized.contains('<'), false, reason: 'Attack blocked: $attack');
          expect(sanitized.toLowerCase().contains('script'), false);
          expect(sanitized.toLowerCase().contains('javascript'), false);
        }
      });

      test('should block reflected XSS attacks', () {
        const reflected = 'javascript:eval(atob("YWxlcnQoMSk="))';
        final sanitized = InputSanitizer.sanitizeProductName(reflected);
        expect(sanitized.toLowerCase().contains('javascript'), false);
      });

      test('should validate against OWASP XSS cheat sheet examples', () {
        // https://cheatsheetseries.owasp.org/cheatsheets/XSS_Filter_Evasion_Cheat_Sheet.html
        final owaspExamples = [
          '<SCRIPT SRC=http://xss.rocks/xss.js></SCRIPT>',
          '<IMG SRC="javascript:alert(\'XSS\');">',
          '<BODY ONLOAD=alert(\'XSS\')>',
          '<<SCRIPT>alert("XSS");//<</SCRIPT>',
        ];

        for (final example in owaspExamples) {
          final sanitized = InputSanitizer.sanitizeProductName(example);
          expect(
            InputSanitizer.isSafeText(sanitized),
            true,
            reason: 'OWASP example sanitized: $example',
          );
        }
      });
    });
  });
}
