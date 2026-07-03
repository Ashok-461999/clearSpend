import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/category.dart';
import '../../domain/models/emi.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/emi_repository.dart';
import '../../domain/repositories/expense_repository.dart';

class EmiState {
  final List<Emi> emis;
  final String? error;

  const EmiState({this.emis = const [], this.error});

  EmiState copyWith({List<Emi>? emis, String? error, bool clearError = false}) {
    return EmiState(
      emis: emis ?? this.emis,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class EmiController extends StateNotifier<EmiState> {
  final EmiRepository _repository;
  final ExpenseRepository _expenseRepository;
  StreamSubscription<List<Emi>>? _subscription;

  EmiController(this._repository, this._expenseRepository)
      : super(const EmiState()) {
    try {
      _subscription = _repository.watchAll().listen((emis) {
        state = state.copyWith(emis: emis);
      });
    } catch (_) {
      // Schema not registered yet — restart app to pick up IsarEmiSchema
      state = state.copyWith(error: 'Restart app to enable EMI storage');
    }
  }

  Future<void> addEmi({
    required String name,
    required int totalAmountMinor,
    required int monthlyAmountMinor,
    required Category category,
    required DateTime startDate,
    required int totalMonths,
    String? notes,
  }) async {
    if (name.trim().isEmpty) {
      state = state.copyWith(error: 'Enter a name for the EMI');
      return;
    }
    if (monthlyAmountMinor <= 0) {
      state = state.copyWith(error: 'Enter a valid monthly amount');
      return;
    }

    state = state.copyWith(clearError: true);

    await _repository.save(Emi(
      name: name.trim(),
      totalAmountMinor: totalAmountMinor,
      monthlyAmountMinor: monthlyAmountMinor,
      category: category,
      startDate: startDate,
      totalMonths: totalMonths,
      notes: notes?.trim(),
    ));
  }

  Future<void> markPaid(int id) async {
    final emi = state.emis.where((e) => e.id == id).firstOrNull;
    if (emi == null || emi.isCompleted) return;
    final updated = emi.copyWith(paidMonths: emi.paidMonths + 1);
    await _repository.save(updated);
    await _expenseRepository.save(Expense(
      amountMinor: emi.monthlyAmountMinor,
      category: emi.category,
      dateUtc: DateTime.now().toUtc(),
      notes: 'EMI: ${emi.name}',
    ));
  }

  Future<void> deleteEmi(int id) async {
    await _repository.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
