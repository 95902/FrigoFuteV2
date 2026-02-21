import 'package:flutter_test/flutter_test.dart';
import 'package:frigofute_v2/core/validation/password_validator.dart';

/// Unit tests for PasswordValidator
/// Story 1.1: Create Account with Email and Password
///
/// Tests password strength validation and calculation
void main() {
  group('PasswordValidator', () {
    group('validate()', () {
      test('should return null for valid passwords', () {
        expect(PasswordValidator.validate('password123'), null);
        expect(PasswordValidator.validate('12345678'), null);
        expect(PasswordValidator.validate('VeryLongPassword123!@#'), null);
      });

      test('should return error for empty password', () {
        expect(PasswordValidator.validate(''), 'Password is required');
      });

      test('should return error for password less than 8 characters', () {
        expect(PasswordValidator.validate('1234567'), 'Password must be at least 8 characters');
        expect(PasswordValidator.validate('abc'), 'Password must be at least 8 characters');
        expect(PasswordValidator.validate('1'), 'Password must be at least 8 characters');
      });

      test('should return error for password more than 128 characters', () {
        final longPassword = 'a' * 129;
        expect(
          PasswordValidator.validate(longPassword),
          'Password must be less than 128 characters',
        );
      });

      test('should accept password with exactly 8 characters', () {
        expect(PasswordValidator.validate('12345678'), null);
      });

      test('should accept password with exactly 128 characters', () {
        final maxPassword = 'a' * 128;
        expect(PasswordValidator.validate(maxPassword), null);
      });
    });

    group('calculateStrength()', () {
      test('should return 0.2 for 8-char password with only lowercase', () {
        final strength = PasswordValidator.calculateStrength('abcdefgh');
        expect(strength, 0.35); // 0.2 (length >=8) + 0.15 (lowercase)
      });

      test('should return higher score for mixed character types', () {
        final strength = PasswordValidator.calculateStrength('Password1!');
        expect(strength, greaterThan(0.6));
        expect(strength, lessThanOrEqualTo(1.0));
      });

      test('should return maximum 1.0 for very strong password', () {
        final strength = PasswordValidator.calculateStrength('VeryStr0ng!Pass123');
        expect(strength, 1.0);
      });

      test('should give higher score for longer passwords', () {
        final short = PasswordValidator.calculateStrength('Pass1!ab'); // 8 chars
        final long = PasswordValidator.calculateStrength('Password123!Long'); // 16 chars
        expect(long, greaterThan(short));
      });

      test('should reward character variety', () {
        final simple = PasswordValidator.calculateStrength('12345678'); // Only numbers
        final complex = PasswordValidator.calculateStrength('Pass123!'); // Mixed
        expect(complex, greaterThan(simple));
      });

      test('should return low score for very short password', () {
        final strength = PasswordValidator.calculateStrength('abc'); // 3 chars
        expect(strength, lessThan(0.3));
      });
    });

    group('getStrengthLabel()', () {
      test('should return "Weak" for strength < 0.3', () {
        expect(PasswordValidator.getStrengthLabel(0.0), 'Weak');
        expect(PasswordValidator.getStrengthLabel(0.2), 'Weak');
        expect(PasswordValidator.getStrengthLabel(0.29), 'Weak');
      });

      test('should return "Fair" for strength 0.3 to 0.6', () {
        expect(PasswordValidator.getStrengthLabel(0.3), 'Fair');
        expect(PasswordValidator.getStrengthLabel(0.5), 'Fair');
        expect(PasswordValidator.getStrengthLabel(0.59), 'Fair');
      });

      test('should return "Good" for strength 0.6 to 0.8', () {
        expect(PasswordValidator.getStrengthLabel(0.6), 'Good');
        expect(PasswordValidator.getStrengthLabel(0.7), 'Good');
        expect(PasswordValidator.getStrengthLabel(0.79), 'Good');
      });

      test('should return "Strong" for strength >= 0.8', () {
        expect(PasswordValidator.getStrengthLabel(0.8), 'Strong');
        expect(PasswordValidator.getStrengthLabel(0.9), 'Strong');
        expect(PasswordValidator.getStrengthLabel(1.0), 'Strong');
      });
    });

    group('Constants', () {
      test('minLength should be 8', () {
        expect(PasswordValidator.minLength, 8);
      });

      test('maxLength should be 128', () {
        expect(PasswordValidator.maxLength, 128);
      });
    });
  });
}
