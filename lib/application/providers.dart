import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/category.dart';
import '../core/date_range.dart';
import '../core/money.dart';
import '../data/repositories/isar_category_budget_repository.dart';
import '../data/repositories/isar_emi_repository.dart';
import '../data/repositories/isar_expense_repository.dart';
import '../data/repositories/isar_goal_repository.dart';
import '../data/repositories/isar_investment_repository.dart';
import '../data/repositories/isar_khata_repository.dart';
import '../data/repositories/isar_sip_installment_repository.dart';
import '../data/repositories/isar_trade_repository.dart';
import '../domain/models/expense.dart';
import '../domain/repositories/category_budget_repository.dart';
import '../domain/repositories/emi_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/goal_repository.dart';
import '../domain/repositories/investment_repository.dart';
import '../domain/repositories/khata_repository.dart';
import '../domain/repositories/sip_installment_repository.dart';
import '../domain/repositories/trade_repository.dart';
import 'budget/budget_hive_controller.dart';
import 'coins/coin_controller.dart';
import 'emi/emi_controller.dart';
import 'expense/expense_form_controller.dart';
import 'history/history_controller.dart';
import 'investment/investment_controller.dart';
import 'khata/khata_controller.dart';
import 'settings/app_settings.dart';
import 'settings/settings_controller.dart';
import 'trade/trade_controller.dart';

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

final khataRepositoryProvider = Provider<KhataRepository>((ref) {
  return IsarKhataRepository(ref.watch(isarProvider));
});

final khataControllerProvider =
    StateNotifierProvider<KhataController, KhataState>((ref) {
  return KhataController(
    ref.watch(khataRepositoryProvider),
  );
});

final coinControllerProvider =
    StateNotifierProvider<CoinController, CoinState>((ref) {
  return CoinController(
    ref.watch(sharedPreferencesProvider),
    ref.watch(coinHistoryBoxProvider),
  );
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
    if (e.isWaste) wasted += e.amountMinor;
  }
  return wasted;
});

final tradeRepositoryProvider = Provider<TradeRepository>((ref) {
  return IsarTradeRepository(ref.watch(isarProvider));
});

final tradeControllerProvider =
    StateNotifierProvider<TradeController, TradeState>((ref) {
  return TradeController(ref.watch(tradeRepositoryProvider));
});

final categoryBudgetRepositoryProvider =
    Provider<CategoryBudgetRepository>((ref) {
  return IsarCategoryBudgetRepository(ref.watch(isarProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return IsarGoalRepository(ref.watch(isarProvider));
});

final budgetControllerProvider =
    StateNotifierProvider<BudgetHiveController, BudgetHiveState>((ref) {
  final budgetBox = ref.watch(budgetHiveBoxProvider);
  final goalsBox = ref.watch(goalsHiveBoxProvider);
  final nextId = ref.watch(nextGoalIdProvider);
  final ctrl = BudgetHiveController(budgetBox, goalsBox, nextId);

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 1);
  ref.watch(expenseRepositoryProvider).watchInRange(start: start, end: end).listen((exps) {
    ctrl.injectMonthExpenses(exps);
  });

  return ctrl;
});

final investmentRepositoryProvider = Provider<InvestmentRepository>((ref) {
  return IsarInvestmentRepository(ref.watch(isarProvider));
});

final investmentControllerProvider =
    StateNotifierProvider<InvestmentController, InvestmentState>((ref) {
  return InvestmentController(
    ref.watch(investmentRepositoryProvider),
    ref.watch(sipInstallmentRepositoryProvider),
  );
});

final sipInstallmentRepositoryProvider =
    Provider<SipInstallmentRepository>((ref) {
  return IsarSipInstallmentRepository(ref.watch(isarProvider));
});

final includeInvestmentsInNetWorthProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('include_investments_in_net_worth') ?? false;
});
