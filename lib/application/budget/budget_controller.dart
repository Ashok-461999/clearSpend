import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/category.dart';
import '../../domain/models/category_budget.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/goal.dart';
import '../../domain/repositories/category_budget_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/goal_repository.dart';

class BudgetState {
  final List<CategoryBudget> budgets;
  final List<Goal> goals;
  final List<Expense> monthExpenses;

  const BudgetState({
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
}

class BudgetController extends StateNotifier<BudgetState> {
  final CategoryBudgetRepository _budgetRepo;
  final GoalRepository _goalRepo;
  final ExpenseRepository _expenseRepo;
  StreamSubscription<List<CategoryBudget>>? _budgetSub;
  StreamSubscription<List<Goal>>? _goalSub;
  StreamSubscription<List<Expense>>? _expenseSub;

  BudgetController(this._budgetRepo, this._goalRepo, this._expenseRepo)
      : super(const BudgetState()) {
    _budgetSub = _budgetRepo.watchAll().listen(
        (budgets) => state = state.copyWith(budgets: budgets));
    _goalSub = _goalRepo.watchAll().listen(
        (goals) => state = state.copyWith(goals: goals));
    _watchMonthExpenses();
  }

  void _watchMonthExpenses() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    _expenseSub = _expenseRepo
        .watchInRange(start: start, end: end)
        .listen((exps) => state = state.copyWith(monthExpenses: exps));
  }

  Future<void> setBudget(Category category, int limit) async {
    final now = DateTime.now();
    final ym = now.year * 100 + now.month;
    final existing = state.budgets.where(
      (b) => b.category == category && b.yearMonth == ym,
    ).firstOrNull;

    if (limit <= 0) {
      if (existing != null) await _budgetRepo.delete(existing.id!);
      return;
    }

    await _budgetRepo.save(CategoryBudget(
      id: existing?.id,
      category: category,
      monthlyLimit: limit,
      yearMonth: ym,
    ));
  }

  Future<void> addGoal(Goal goal) async {
    await _goalRepo.save(goal);
  }

  Future<void> contributeToGoal(int goalId, int amount) async {
    final goal = state.goals.firstWhere((g) => g.id == goalId);
    await _goalRepo.save(goal.copyWith(
      currentAmount: goal.currentAmount + amount,
    ));
  }

  Future<void> deleteGoal(int id) async {
    await _goalRepo.delete(id);
  }

  @override
  void dispose() {
    _budgetSub?.cancel();
    _goalSub?.cancel();
    _expenseSub?.cancel();
    super.dispose();
  }
}

extension BudgetStateX on BudgetState {
  BudgetState copyWith({
    List<CategoryBudget>? budgets,
    List<Goal>? goals,
    List<Expense>? monthExpenses,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
      monthExpenses: monthExpenses ?? this.monthExpenses,
    );
  }
}
