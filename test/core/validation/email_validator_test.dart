import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/validation/email_validator.dart';

/// Unit tests for EmailValidator
/// Story 1.1: Create Account with Email and Password
///
/// Tests email format validation and normalization
void main() {
  group('EmailValidator', () {
    group('validate()', () {
      test('should return null for valid email formats', () {
        expect(EmailValidator.validate('user@example.com'), null);
        expect(EmailValidator.validate('test.user@example.com'), null);
        expect(EmailValidator.validate('user+tag@example.co.uk'), null);
        expect(EmailValidator.validate('user.name+tag@example.io'), null);
      });

      test('should return error for empty email', () {
        expect(EmailValidator.validate(''), 'Email is required');
      });

      test('should return error for invalid email formats', () {
        expect(EmailValidator.validate('invalid-email'), isNotNull);
        expect(EmailValidator.validate('user@'), isNotNull);
        expect(EmailValidator.validate('@example.com'), isNotNull);
        expect(EmailValidator.validate('user@example'), isNotNull);
        expect(EmailValidator.validate('user@.com'), isNotNull);
        expect(EmailValidator.validate('user..name@example.com'), isNotNull);
      });

      test('should handle edge cases', () {
        expect(EmailValidator.validate('a@b.co'), null); // Min valid
        expect(EmailValidator.validate('user@sub.domain.example.com'), null); // Subdomain
      });
    });

    group('normalize()', () {
      test('should convert email to lowercase', () {
        expect(EmailValidator.normalize('User@Example.COM'), 'user@example.com');
        expect(EmailValidator.normalize('TEST@DOMAIN.FR'), 'test@domain.fr');
      });

      test('should trim whitespace', () {
        expect(EmailValidator.normalize('  user@example.com  '), 'user@example.com');
        expect(EmailValidator.normalize('user@example.com '), 'user@example.com');
      });

      test('should handle already normalized emails', () {
        expect(EmailValidator.normalize('user@example.com'), 'user@example.com');
      });
    });
  });
}
