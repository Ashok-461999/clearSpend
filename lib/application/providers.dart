import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/category.dart';
import '../core/date_range.dart';
import '../data/repositories/isar_emi_repository.dart';
import '../data/repositories/isar_expense_repository.dart';
import '../domain/models/expense.dart';
import '../domain/repositories/emi_repository.dart';
import '../domain/repositories/expense_repository.dart';
import 'coins/coin_controller.dart';
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
  return ExpenseFormController(
    ref.watch(expenseRepositoryProvider),
    ref.watch(coinControllerProvider.notifier),
  );
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

final accountBalanceProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final start = DateTime(2000);
  final end = DateTime(2100);
  return repo.watchInRange(start: start, end: end).map((expenses) {
    final income = expenses.where((e) => e.isIncome).fold<int>(0, (sum, e) => sum + e.amountMinor);
    final expense = expenses.where((e) => !e.isIncome).fold<int>(0, (sum, e) => sum + e.amountMinor);
    return income - expense;
  });
});

final budgetProgressProvider = Provider<double>((ref) {
  final historyState = ref.watch(historyControllerProvider);
  final budget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
  if (budget <= 0) return 0;
  return (historyState.totalExpense / budget).clamp(0, 2);
});

final budgetRemainingProvider = Provider<int>((ref) {
  final historyState = ref.watch(historyControllerProvider);
  final budget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
  return budget - historyState.totalExpense;
});

final spendingScoreProvider = Provider<int>((ref) {
  final progress = ref.watch(budgetProgressProvider);
  if (progress <= 0) return 100;
  final score = ((1 - progress) * 100).round().clamp(0, 100);
  return score;
});

final dailyAverageProvider = Provider<int>((ref) {
  final historyState = ref.watch(historyControllerProvider);
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final day = now.day.clamp(1, daysInMonth);
  if (day == 0 || historyState.totalExpense <= 0) return 0;
  return historyState.totalExpense ~/ day;
});

final projectedMonthEndProvider = Provider<int>((ref) {
  final avg = ref.watch(dailyAverageProvider);
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final remaining = daysInMonth - now.day;
  final historyState = ref.watch(historyControllerProvider);
  return historyState.totalExpense + (avg * remaining);
});

final savingsGoalProvider = StateProvider<int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getInt('savings_goal') ?? 0;
});

final coinControllerProvider =
    StateNotifierProvider<CoinController, CoinState>((ref) {
  return CoinController(ref.watch(sharedPreferencesProvider));
});

final monthExpensesProvider = Provider<List<Expense>>((ref) {
  final state = ref.watch(historyControllerProvider);
  return state.days.expand((d) => d.expenses).toList();
});

final categoryTotalsProvider = Provider<List<MapEntry<Category, int>>>((ref) {
  final expenses = ref.watch(monthExpensesProvider);
  final totals = <Category, int>{};
  for (final e in expenses) {
    if (e.isIncome) continue;
    totals.update(e.category, (v) => v + e.amountMinor, ifAbsent: () => e.amountMinor);
  }
  final sorted = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted;
});

final wastedTotalProvider = Provider<int>((ref) {
  final expenses = ref.watch(monthExpensesProvider);
  int wasted = 0;
  for (final e in expenses) {
    if (e.isIncome) continue;
    if (!e.category.isEssential) wasted += e.amountMinor;
  }
  return wasted;
});
