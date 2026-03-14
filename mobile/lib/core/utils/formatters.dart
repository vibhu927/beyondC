import 'package:intl/intl.dart';

class Formatters {
  /// Format currency from paise (100 paise = ₹1)
  /// Example: 150000 paise → ₹1,500
  static String currency(int paise) {
    final inr = paise / 100;
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: inr % 1 == 0 ? 0 : 2,
    );
    return formatter.format(inr);
  }

  /// Format currency from INR integer
  /// Example: 1500 → ₹1,500
  static String currencyFromINR(int inr) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(inr);
  }

  /// Format follower count with K/M suffix
  /// Example: 18200 → 18.2K, 1200000 → 1.2M
  static String followerCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final k = count / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    } else {
      final m = count / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    }
  }

  /// Get follower range string based on count
  /// Example: 35000 → "10K–50K" (micro tier)
  static String followerRange(int count) {
    if (count < 1000) {
      return '<1K';
    } else if (count < 10000) {
      return '1K–10K';
    } else if (count < 50000) {
      return '10K–50K';
    } else if (count < 250000) {
      return '50K–250K';
    } else {
      return '250K+';
    }
  }

  /// Format relative time (timeago)
  /// Example: "2 days ago", "5 hours ago"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Format date
  /// Example: "15 Feb 2025"
  static String date(DateTime dateTime) {
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  /// Format time
  /// Example: "7:00 PM"
  static String time(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format date and time
  /// Example: "15 Feb 2025, 7:00 PM"
  static String dateTime(DateTime dateTime) {
    return '${date(dateTime)}, ${time(dateTime)}';
  }
}
