import 'money.dart';

class UpiData {
  final String? vpa;
  final String? name;
  final int? amountMinor;
  final String? transactionNote;
  final String? transactionRef;

  const UpiData({
    this.vpa,
    this.name,
    this.amountMinor,
    this.transactionNote,
    this.transactionRef,
  });
}

class UpiParser {
  static bool isUpi(String raw) =>
      raw.trim().toLowerCase().startsWith('upi://');

  static UpiData? parse(String raw) {
    final uri = raw.trim();
    if (!isUpi(uri)) return null;

    final queryStart = uri.indexOf('?');
    if (queryStart < 0) return UpiData();

    final query = uri.substring(queryStart + 1);
    final params = <String, String>{};
    for (final part in query.split('&')) {
      final eq = part.indexOf('=');
      if (eq > 0) {
        final key = _decode(part.substring(0, eq)).toLowerCase();
        final value = _decode(part.substring(eq + 1));
        params[key] = value;
      }
    }

    final amountStr = params['am'];
    final amountMinor = amountStr != null
        ? Money.parseToMinor(amountStr)
        : null;

    return UpiData(
      vpa: params['pa'],
      name: params['pn'],
      amountMinor: amountMinor,
      transactionNote: params['tn'],
      transactionRef: params['tr'],
    );
  }

  static String _decode(String s) {
    return s.replaceAll('+', ' ');
  }
}
