import 'package:flutter_test/flutter_test.dart';

import '../../lib/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name+tag@domain.co.uk'), null);
        expect(Validators.validateEmail('test.email@subdomain.domain.com'), null);
      });

      test('should return error for invalid email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('@domain.com'), isNotNull);
        expect(Validators.validateEmail('user@'), isNotNull);
        expect(Validators.validateEmail('user@domain'), isNotNull);
      });

      test('normalizeEmail should convert to lowercase and trim', () {
        expect(Validators.normalizeEmail('  PP.NAMIAS@GMAIL.COM  '), 'pp.namias@gmail.com');
        expect(Validators.normalizeEmail('Test.User@Example.Com'), 'test.user@example.com');
        expect(Validators.normalizeEmail('user@domain.com'), 'user@domain.com');
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        expect(Validators.validatePassword('StrongPass123!'), null);
        expect(Validators.validatePassword('MyPassword123#'), null);
        expect(Validators.validatePassword('Test@123456789'), null);
      });

      test('should return error for invalid password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
        expect(Validators.validatePassword('weak'), isNotNull); // too short
        expect(Validators.validatePassword('weakpassword'), isNotNull); // no uppercase, number, special
        expect(Validators.validatePassword('Weakpassword'), isNotNull); // no number, special
        expect(Validators.validatePassword('Weakpassword123'), isNotNull); // no special
        expect(Validators.validatePassword('weakpassword!'), isNotNull); // no uppercase, number
        expect(Validators.validatePassword('WEAKPASSWORD!'), isNotNull); // no number
      });
    });

    group('validateConfirmPassword', () {
      test('should return null when passwords match', () {
        expect(Validators.validateConfirmPassword('password123', 'password123'), null);
        expect(Validators.validateConfirmPassword('StrongPass123!', 'StrongPass123!'), null);
      });

      test('should return error when passwords do not match', () {
        expect(Validators.validateConfirmPassword('password123', 'password124'), isNotNull);
        expect(Validators.validateConfirmPassword('', 'password123'), isNotNull);
        expect(Validators.validateConfirmPassword(null, 'password123'), isNotNull);
      });
    });

    group('validateName', () {
      test('should return null for valid names', () {
        expect(Validators.validateName('John', 'First name'), null);
        expect(Validators.validateName('Smith-Jones', 'Last name'), null);
        expect(Validators.validateName('Mary Jane', 'First name'), null);
        expect(Validators.validateName('O\'Connor', 'Last name'), null);
      });

      test('should return error for invalid names', () {
        expect(Validators.validateName('', 'First name'), isNotNull);
        expect(Validators.validateName(null, 'First name'), isNotNull);
        expect(Validators.validateName('A', 'First name'), isNotNull); // too short
        expect(Validators.validateName('John123', 'First name'), isNotNull); // contains numbers
        expect(Validators.validateName('John@Doe', 'First name'), isNotNull); // contains special chars
        expect(Validators.validateName('This is a very long name that exceeds fifty characters and should fail validation', 'First name'), isNotNull); // too long
      });
    });

    group('validatePhone', () {
      test('should return null for valid Philippine phone numbers', () {
        expect(Validators.validatePhone('09123456789'), null);
        expect(Validators.validatePhone('639123456789'), null);
      });

      test('should return null for empty phone (optional)', () {
        expect(Validators.validatePhone(''), null);
        expect(Validators.validatePhone(null), null);
      });

      test('should return error for invalid phone numbers', () {
        expect(Validators.validatePhone('123456789'), isNotNull); // wrong format
        expect(Validators.validatePhone('0912345678'), isNotNull); // too short
        expect(Validators.validatePhone('091234567890'), isNotNull); // too long
        expect(Validators.validatePhone('63912345678'), isNotNull); // international too short
        expect(Validators.validatePhone('6391234567890'), isNotNull); // international too long
      });
    });

    group('formatPhoneNumber', () {
      test('should format Philippine mobile numbers correctly', () {
        expect(Validators.formatPhoneNumber('09123456789'), '+63 912 345 6789');
        expect(Validators.formatPhoneNumber('639123456789'), '+63 912 345 6789');
      });

      test('should return original for unformattable numbers', () {
        expect(Validators.formatPhoneNumber('123456789'), '123456789');
        expect(Validators.formatPhoneNumber('invalid'), 'invalid');
      });
    });
  });
}