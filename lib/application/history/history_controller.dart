import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/category.dart';
import '../../core/date_range.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class DayGroup {
  final DateTime date;
  final List<Expense> expenses;
  final int total;
  final int incomeTotal;
  final int expenseTotal;

  const DayGroup({
    required this.date,
    required this.expenses,
    required this.total,
    this.incomeTotal = 0,
    this.expenseTotal = 0,
  });
}

class HistoryState {
  final DateRangeType rangeType;
  final int year;
  final int month;
  final DateTime? customStart;
  final DateTime? customEnd;
  final Category? categoryFilter;
  final List<DayGroup> days;
  final int? _total;
  int get total => _total ?? 0;
  final int? _totalIncome;
  int get totalIncome => _totalIncome ?? 0;
  final int? _totalExpense;
  int get totalExpense => _totalExpense ?? 0;

  const HistoryState({
    this.rangeType = DateRangeType.month,
    required this.year,
    required this.month,
    this.customStart,
    this.customEnd,
    this.categoryFilter,
    this.days = const [],
    int total = 0,
    int totalIncome = 0,
    int totalExpense = 0,
  }) : _total = total,
       _totalIncome = totalIncome,
       _totalExpense = totalExpense;

  HistoryState copyWith({
    DateRangeType? rangeType,
    int? year,
    int? month,
    DateTime? customStart,
    DateTime? customEnd,
    bool clearCustom = false,
    Category? categoryFilter,
    bool clearFilter = false,
    List<DayGroup>? days,
    int? total,
    int? totalIncome,
    int? totalExpense,
  }) {
    return HistoryState(
      rangeType: rangeType ?? this.rangeType,
      year: year ?? this.year,
      month: month ?? this.month,
      customStart: clearCustom ? null : (customStart ?? this.customStart),
      customEnd: clearCustom ? null : (customEnd ?? this.customEnd),
      categoryFilter: clearFilter ? null : (categoryFilter ?? this.categoryFilter),
      days: days ?? this.days,
      total: total ?? _total ?? 0,
      totalIncome: totalIncome ?? _totalIncome ?? 0,
      totalExpense: totalExpense ?? _totalExpense ?? 0,
    );
  }
}

class HistoryController extends StateNotifier<HistoryState> {
  final ExpenseRepository _repository;
  StreamSubscription<List<Expense>>? _subscription;

  HistoryController(this._repository, {DateRangeType defaultRange = DateRangeType.month})
      : super(HistoryState(
          rangeType: defaultRange,
          year: DateTime.now().year,
          month: DateTime.now().month,
        )) {
    _reload();
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      rangeType: DateRangeType.custom,
      customStart: start,
      customEnd: end,
      year: start.year,
      month: start.month,
    );
    _reload();
  }

  void setRangeType(DateRangeType type) {
    final now = DateTime.now();
    state = state.copyWith(
      rangeType: type,
      year: now.year,
      month: now.month,
      clearCustom: true,
    );
    _reload();
  }

  void setCategory(Category? category) {
    state = state.copyWith(
      categoryFilter: category,
      clearFilter: category == null,
    );
    _reload();
  }

  void setMonth(int year, int month) {
    state = state.copyWith(
      rangeType: DateRangeType.month,
      year: year,
      month: month,
    );
    _reload();
  }

  void previousMonth() {
    var y = state.year;
    var m = state.month - 1;
    if (m == 0) {
      m = 12;
      y--;
    }
    setMonth(y, m);
  }

  void nextMonth() {
    var y = state.year;
    var m = state.month + 1;
    if (m == 13) {
      m = 1;
      y++;
    }
    setMonth(y, m);
  }

  void _reload() {
    _subscription?.cancel();

    final bounds = switch (state.rangeType) {
      DateRangeType.today => todayBounds(),
      DateRangeType.week => weekBounds(),
      DateRangeType.month => monthBounds(state.year, state.month),
      DateRangeType.year => yearBounds(state.year),
      DateRangeType.custom => (start: state.customStart!, end: state.customEnd!),
    };

    _subscription = _repository
        .watchInRange(
          start: bounds.start,
          end: bounds.end,
          category: state.categoryFilter,
        )
        .listen(_onData);
  }

  void _onData(List<Expense> expenses) {
    final grouped = <DateTime, List<Expense>>{};
    for (final e in expenses) {
      final day = DateTime(
        e.localDate.year,
        e.localDate.month,
        e.localDate.day,
      );
      grouped.putIfAbsent(day, () => []).add(e);
    }

    final days = grouped.entries
        .map((e) {
          final incomeTotal = e.value
              .where((x) => x.isIncome)
              .fold<int>(0, (sum, x) => sum + x.amountMinor);
          final expenseTotal = e.value
              .where((x) => !x.isIncome)
              .fold<int>(0, (sum, x) => sum + x.amountMinor);
          return DayGroup(
            date: e.key,
            expenses: e.value,
            total: expenseTotal,
            incomeTotal: incomeTotal,
            expenseTotal: expenseTotal,
          );
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalIncome =
        expenses.where((e) => e.isIncome).fold<int>(0, (sum, e) => sum + e.amountMinor);
    final totalExpense =
        expenses.where((e) => !e.isIncome).fold<int>(0, (sum, e) => sum + e.amountMinor);

    state = state.copyWith(days: days, total: totalExpense, totalIncome: totalIncome, totalExpense: totalExpense);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
