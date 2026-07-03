import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/category.dart';
import '../../core/money.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseFormState {
  final int? editingId;
  final String amountText;
  final Category? category;
  final String notes;
  final DateTime date;
  final bool isSubmitting;
  final String? error;

  const ExpenseFormState({
    this.editingId,
    this.amountText = '',
    this.category,
    this.notes = '',
    required this.date,
    this.isSubmitting = false,
    this.error,
  });

  ExpenseFormState copyWith({
    int? editingId,
    String? amountText,
    Category? category,
    String? notes,
    DateTime? date,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return ExpenseFormState(
      editingId: editingId ?? this.editingId,
      amountText: amountText ?? this.amountText,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ExpenseFormController extends StateNotifier<ExpenseFormState> {
  final ExpenseRepository _repository;

  ExpenseFormController(this._repository)
      : super(ExpenseFormState(date: DateTime.now()));

  void setAmount(String value) {
    state = state.copyWith(amountText: value, clearError: true);
  }

  void setCategory(Category category) {
    state = state.copyWith(category: category, clearError: true);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date, clearError: true);
  }

  void loadForEdit(Expense expense) {
    state = ExpenseFormState(
      editingId: expense.id,
      amountText: Money.toEditString(expense.amountMinor),
      category: expense.category,
      notes: expense.notes ?? '',
      date: expense.localDate,
    );
  }

  Future<bool> submit({int currentMonthExpense = 0, int monthlyBudget = 0}) async {
    final amount = Money.parseToMinor(state.amountText);
    if (amount == null) {
      state = state.copyWith(error: 'Enter a valid amount');
      return false;
    }
    if (state.category == null) {
      state = state.copyWith(error: 'Select a category');
      return false;
    }

    if (monthlyBudget > 0 && state.category != null && !state.category!.isIncome) {
      final newTotal = currentMonthExpense + amount;
      if (newTotal > monthlyBudget) {
        state = state.copyWith(error: 'This expense exceeds your monthly budget! (\$${Money.format(monthlyBudget)})');
        return false;
      }
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.save(Expense.fromLocal(
        id: state.editingId,
        amountMinor: amount,
        category: state.category!,
        localDate: state.date,
        notes: state.notes.isNotEmpty ? state.notes : null,
      ));
      state = ExpenseFormState(date: DateTime.now());
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to save: $e',
      );
      return false;
    }
  }

  void reset() {
    state = ExpenseFormState(date: DateTime.now());
  }
}
