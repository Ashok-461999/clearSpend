import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/date_range.dart';
import '../data/repositories/isar_emi_repository.dart';
import '../data/repositories/isar_expense_repository.dart';
import '../domain/repositories/emi_repository.dart';
import '../domain/repositories/expense_repository.dart';
import 'emi/emi_controller.dart';
import 'expense/expense_form_controller.dart';
import 'history/history_controller.dart';
import 'settings/settings_controller.dart';

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return IsarExpenseRepository(ref.watch(isarProvider));
});

final expenseFormControllerProvider =
    StateNotifierProvider<ExpenseFormController, ExpenseFormState>((ref) {
  return ExpenseFormController(ref.watch(expenseRepositoryProvider));
});

final historyControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final defaultRange = ref.watch(defaultRangeTypeProvider);
  return HistoryController(
    ref.watch(expenseRepositoryProvider),
    defaultRange: defaultRange,
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final saved = prefs.getString('theme_mode');
  switch (saved) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

final defaultRangeTypeProvider = StateProvider<DateRangeType>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final saved = prefs.getInt('default_range_type');
  if (saved != null && saved >= 0 && saved < DateRangeType.values.length) {
    return DateRangeType.values[saved];
  }
  return DateRangeType.month;
});

final emiRepositoryProvider = Provider<EmiRepository>((ref) {
  return IsarEmiRepository(ref.watch(isarProvider));
});

final emiControllerProvider =
    StateNotifierProvider<EmiController, EmiState>((ref) {
  return EmiController(
    ref.watch(emiRepositoryProvider),
    ref.watch(expenseRepositoryProvider),
  );
});

final analysisControllerProvider =
    StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final defaultRange = ref.watch(defaultRangeTypeProvider);
  return HistoryController(
    ref.watch(expenseRepositoryProvider),
    defaultRange: defaultRange,
  );
});

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsController(prefs);
});

final remainingBalanceProvider = Provider<int>((ref) {
  final historyState = ref.watch(historyControllerProvider);
  final settings = ref.watch(settingsControllerProvider);
  return settings.profile.initialBalance + historyState.totalIncome - historyState.totalExpense;
});
