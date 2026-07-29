import 'package:flutter_test/flutter_test.dart';
import 'package:beyondc/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('currency formats paise correctly', () {
      expect(Formatters.currency(100000), '₹1,000');
      expect(Formatters.currency(500), '₹5');
      expect(Formatters.currency(0), '₹0');
    });

    test('followerCount formats large numbers', () {
      expect(Formatters.followerCount(1000), '1K');
      expect(Formatters.followerCount(1500), '1.5K');
      expect(Formatters.followerCount(100000), '100K');
      expect(Formatters.followerCount(1000000), '1M');
    });

    test('date formats DateTime', () {
      final formatted = Formatters.date(DateTime(2026, 6, 15));
      expect(formatted, '15 Jun 2026');
    });

    test('timeAgo returns relative time string', () {
      final now = DateTime.now();
      final fiveMinAgo = now.subtract(const Duration(minutes: 5));
      final result = Formatters.timeAgo(fiveMinAgo);
      expect(result, contains('minute'));
    });
  });
}
