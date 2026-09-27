import 'package:flutter_test/flutter_test.dart';
import 'package:neet_paper_test/core/auth/auth_service.dart';

void main() {
  group('AuthService Phone Normalization Tests', () {
    test('standard 10-digit number remains unchanged', () {
      expect(AuthService.normalizePhone('9876543210'), '9876543210');
    });

    test('strips +91 prefix and spaces', () {
      expect(AuthService.normalizePhone('+91 9876543210'), '9876543210');
      expect(AuthService.normalizePhone('+919876543210'), '9876543210');
      expect(AuthService.normalizePhone('+91 98765 43210'), '9876543210');
    });

    test('strips 91 prefix without plus sign', () {
      expect(AuthService.normalizePhone('919876543210'), '9876543210');
    });

    test('strips leading 0', () {
      expect(AuthService.normalizePhone('09876543210'), '9876543210');
    });

    test('strips hyphens, parentheses, and dashes', () {
      expect(AuthService.normalizePhone('98765-43210'), '9876543210');
      expect(AuthService.normalizePhone('(98765) 43210'), '9876543210');
    });
  });
}
