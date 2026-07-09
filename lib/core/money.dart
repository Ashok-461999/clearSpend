import 'package:intl/intl.dart';

class Money {
  Money._();

  static String get symbol => '₹';

  static int? parseToMinor(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null || value <= 0 || !value.isFinite) return null;
    final minor = (value * 100).round();
    if (minor <= 0) return null;
    return minor;
  }

  static String format(int minor) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2)
        .format(minor / 100);
  }

  static String toEditString(int minor) => (minor / 100).toStringAsFixed(2);
}
