import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

final biometricLockProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('biometricLock', defaultValue: false) as bool;
});

final notifyDailyExpenseProvider = StateProvider<bool>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('notifyDailyExpense', defaultValue: false) as bool;
});

final dailyReminderHourProvider = StateProvider<int>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('dailyReminderHour', defaultValue: 20) as int;
});

final dailyReminderMinuteProvider = StateProvider<int>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box.get('dailyReminderMinute', defaultValue: 0) as int;
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
