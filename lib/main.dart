import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'application/budget/budget_hive_controller.dart';
import 'application/coins/coin_controller.dart';
import 'application/providers.dart';
import 'application/settings/app_settings.dart';
import 'core/notification_service.dart';
import 'data/sources/isar_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Hive.initFlutter();
  } catch (_) {}

  final settingsBox = await Hive.openBox('settings');
  final budgetBox = await Hive.openBox('budgets');
  final goalsBox = await Hive.openBox('goals');
  final coinHistoryBox = await Hive.openBox('coin_history');

  final isar = await openIsar();
  final prefs = await SharedPreferences.getInstance();

  try {
    await NotificationService.init();
    final isFirstLaunch = settingsBox.get('first_launch_complete', defaultValue: false) as bool;
    if (!isFirstLaunch) {
      settingsBox.put('dailyReminderHour', 20);
      settingsBox.put('dailyReminderMinute', 0);
      settingsBox.put('first_launch_complete', true);
      await NotificationService.requestAndroidPermission();
    }
    final hour = settingsBox.get('dailyReminderHour', defaultValue: 20) as int;
    final minute = settingsBox.get('dailyReminderMinute', defaultValue: 0) as int;
    await NotificationService.scheduleDailyReminder(hour: hour, minute: minute);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPreferencesProvider.overrideWithValue(prefs),
        settingsBoxProvider.overrideWithValue(settingsBox),
        budgetHiveBoxProvider.overrideWithValue(budgetBox),
        goalsHiveBoxProvider.overrideWithValue(goalsBox),
        coinHistoryBoxProvider.overrideWithValue(coinHistoryBox),
      ],
      child: const ClearSpendApp(),
    ),
  );
}
