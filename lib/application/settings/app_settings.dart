import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

final currencyCodeProvider = Provider<String>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('currencyCode', defaultValue: 'INR') as String;
});

final currencySymbolProvider = Provider<String>((ref) {
  final code = ref.watch(currencyCodeProvider);
  switch (code) {
    case 'USD': return r'$';
    case 'EUR': return '€';
    case 'GBP': return '£';
    case 'JPY': return '¥';
    case 'CNY': return '¥';
    case 'AED': return 'د.إ';
    case 'SAR': return '﷼';
    case 'INR': return '₹';
    default: return '₹';
  }
});

final localeForCurrencyProvider = Provider<String>((ref) {
  final code = ref.watch(currencyCodeProvider);
  switch (code) {
    case 'USD': return 'en_US';
    case 'EUR': return 'de_DE';
    case 'GBP': return 'en_GB';
    case 'JPY': return 'ja_JP';
    case 'CNY': return 'zh_CN';
    case 'AED': return 'ar_AE';
    case 'SAR': return 'ar_SA';
    case 'INR': return 'en_IN';
    default: return 'en_IN';
  }
});

final biometricLockProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('biometricLock', defaultValue: false) as bool;
});

final notifyRecurringProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('notifyRecurring', defaultValue: true) as bool;
});

final notifyEmiProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('notifyEmi', defaultValue: true) as bool;
});

final notifyLedgerProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('notifyLedger', defaultValue: true) as bool;
});

final notifyBudgetProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('notifyBudget', defaultValue: true) as bool;
});

void persistSetting(Box box, String key, dynamic value) {
  box.put(key, value);
}
