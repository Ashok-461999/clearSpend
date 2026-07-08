import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/category.dart';
import '../../domain/models/category_budget.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/goal.dart';

final budgetHiveBoxProvider = Provider<Box>((ref) => throw UnimplementedError());
final goalsHiveBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

final nextGoalIdProvider = StateProvider<int>((ref) {
  final box = ref.watch(goalsHiveBoxProvider);
  return box.get('_nextId', defaultValue: 1) as int;
});

class BudgetHiveState {
  final List<CategoryBudget> budgets;
  final List<Goal> goals;
  final List<Expense> monthExpenses;

  const BudgetHiveState({
    this.budgets = const [],
    this.goals = const [],
    this.monthExpenses = const [],
  });

  int spentForCategory(Category cat) {
    return monthExpenses
        .where((e) => e.category == cat && !e.isIncome)
        .fold<int>(0, (s, e) => s + e.amountMinor);
  }

  int? limitForCategory(Category cat) {
    final now = DateTime.now();
    final ym = now.year * 100 + now.month;
    final b = budgets.where(
      (b) => b.category == cat && b.yearMonth == ym,
    ).firstOrNull;
    return b?.monthlyLimit;
  }

  double progressForCategory(Category cat) {
    final limit = limitForCategory(cat);
    if (limit == null || limit <= 0) return 0;
    return spentForCategory(cat) / limit;
  }

  int get totalBudgeted =>
      budgets.fold<int>(0, (s, b) => s + b.monthlyLimit);

  int get totalSpent =>
      budgets.fold<int>(0, (s, b) => s + spentForCategory(b.category));

  List<MapEntry<Category, (int spent, int? limit)>> get categoryComparisons {
    final cats = Category.values.where((c) => !c.isIncome).toList();
    return cats.map((c) {
      final spent = spentForCategory(c);
      final limit = limitForCategory(c);
      return MapEntry(c, (spent, limit));
    }).where((e) => e.value.$1 > 0 || e.value.$2 != null).toList()
      ..sort((a, b) => (b.value.$2 ?? 0).compareTo(a.value.$2 ?? 0));
  }

  BudgetHiveState copyWith({
    List<CategoryBudget>? budgets,
    List<Goal>? goals,
    List<Expense>? monthExpenses,
  }) {
    return BudgetHiveState(
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
      monthExpenses: monthExpenses ?? this.monthExpenses,
    );
  }
}

class BudgetHiveController extends StateNotifier<BudgetHiveState> {
  final Box _budgetBox;
  final Box _goalBox;
  int _nextGoalId;

  BudgetHiveController(this._budgetBox, this._goalBox, this._nextGoalId)
      : super(const BudgetHiveState()) {
    _loadFromHive();
  }

  void injectMonthExpenses(List<Expense> expenses) {
    if (state.monthExpenses == expenses) return;
    state = state.copyWith(monthExpenses: expenses);
  }

  void _loadFromHive() {
    final budgets = <CategoryBudget>[];
    for (final key in _budgetBox.keys) {
      final val = _budgetBox.get(key);
      if (val is String) {
        try {
          budgets.add(CategoryBudget.fromJsonString(val));
        } catch (_) {}
      }
    }
    budgets.sort((a, b) => a.category.index.compareTo(b.category.index));

    final goals = <Goal>[];
    for (final key in _goalBox.keys) {
      if (key == '_nextId') continue;
      final val = _goalBox.get(key);
      if (val is String) {
        try {
          goals.add(Goal.fromJsonString(val));
        } catch (_) {}
      }
    }
    goals.sort((a, b) => a.deadline.compareTo(b.deadline));

    state = state.copyWith(budgets: budgets, goals: goals);
  }

  Future<void> setBudget(Category category, int limit) async {
    final now = DateTime.now();
    final ym = now.year * 100 + now.month;
    final existing = state.budgets.where(
      (b) => b.category == category && b.yearMonth == ym,
    ).firstOrNull;

    if (limit <= 0) {
      if (existing != null) {
        final key = existing.toJsonString();
        await _budgetBox.delete(key);
      }
      _loadFromHive();
      return;
    }

    final budget = CategoryBudget(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch,
      category: category,
      monthlyLimit: limit,
      yearMonth: ym,
    );
    await _budgetBox.put(budget.key, budget.toJsonString());
    _loadFromHive();
  }

  Future<void> addGoal(Goal goal) async {
    final id = _nextGoalId;
    _nextGoalId++;
    await _goalBox.put('_nextId', _nextGoalId);
    final g = goal.copyWith(id: id, clearId: false);
    await _goalBox.put(id.toString(), g.toJsonString());
    _loadFromHive();
  }

  Future<void> contributeToGoal(int goalId, int amount) async {
    final key = goalId.toString();
    final raw = _goalBox.get(key);
    if (raw == null) return;
    final goal = Goal.fromJsonString(raw as String);
    final updated = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    );
    await _goalBox.put(key, updated.toJsonString());
    _loadFromHive();
  }

  Future<void> deleteGoal(int goalId) async {
    await _goalBox.delete(goalId.toString());
    _loadFromHive();
  }
}

extension CategoryBudgetX on CategoryBudget {
  String get key => '${category.index}_$yearMonth';
}
