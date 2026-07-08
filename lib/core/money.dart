// LAYER: core (shared, depends on nothing in the app)
// RESPONSIBILITY: the ONLY bridge between user-facing decimal text and the
// stored integer minor units (paise). Money is int everywhere it's stored
// or summed — never double. 0.1 + 0.2 != 0.3, and that error compounds
// across a ledger. Parsing and formatting both live here so the rounding
// rule exists in exactly one place.

import 'package:intl/intl.dart';

class Money {
  Money._(); // static-only, no instances

  /// Parse user input ("1234.5", "1,234.50") into integer paise.
  /// Returns null for invalid / zero / negative input — a ₹0 expense is a
  /// data-entry error, not a record, so the caller treats null as "reject".
  static int? parseToMinor(String raw) {
    final cleaned = raw.replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null || value <= 0) return null;
    // Round half-up to the nearest paisa so 12.005 -> 1201, not truncated.
    final minor = (value * 100).round();
    if (minor <= 0) return null;
    return minor;
  }

  static final NumberFormat _fmt =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

  /// Stored paise -> display string. 123450 -> "₹1,234.50".
  static String format(int minor) => _fmt.format(minor / 100);

  /// Format with a custom currency symbol and locale.
  /// 123450 -> "\$1,234.50" when symbol="\$", locale="en_US".
  static String formatWith(int minor, {required String symbol, String locale = 'en_IN'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 2)
        .format(minor / 100);
  }

  /// Stored paise -> plain decimal for prefilling an edit field (no symbol).
  /// 123450 -> "1234.50".
  static String toEditString(int minor) => (minor / 100).toStringAsFixed(2);
}
