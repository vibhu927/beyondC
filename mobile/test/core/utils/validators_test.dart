import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('required returns null for non-empty string', () {
      expect(Validators.required('Hello', 'Name'), isNull);
    });

    test('required returns error for empty string', () {
      expect(Validators.required('', 'Name'), isNotNull);
    });

    test('email returns null for valid email', () {
      expect(Validators.email('test@example.com'), isNull);
    });

    test('email returns error for invalid email', () {
      expect(Validators.email('invalid'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('phone returns null for valid Indian mobile', () {
      expect(Validators.phone('9876543210'), isNull);
    });

    test('phone returns error for invalid phone', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone('0876543210'), isNotNull); // starts with 0
    });

    test('password returns null for strong password', () {
      expect(Validators.password('StrongPass1'), isNull);
    });

    test('password rejects short password', () {
      final result = Validators.password('Ab1');
      expect(result, isNotNull);
      expect(result, contains('8 characters'));
    });

    test('password rejects password without number', () {
      final result = Validators.password('abcdefgh');
      expect(result, isNotNull);
      expect(result, contains('number'));
    });

    test('confirmPassword returns null for match', () {
      expect(Validators.confirmPassword('test123', 'test123'), isNull);
    });

    test('confirmPassword returns error for mismatch', () {
      expect(Validators.confirmPassword('test123', 'different'), isNotNull);
    });
  });
}
