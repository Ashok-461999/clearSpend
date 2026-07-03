import 'package:isar/isar.dart';

import '../../core/category.dart';
import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../sources/isar_expense.dart';

class IsarExpenseRepository implements ExpenseRepository {
  final Isar isar;

  IsarExpenseRepository(this.isar);

  @override
  Future<int> save(Expense expense) async {
    final row = IsarExpense.fromDomain(expense);
    await isar.writeTxn(() async {
      await isar.isarExpenses.put(row);
    });
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.isarExpenses.delete(id);
    });
  }

  @override
  Stream<List<Expense>> watchInRange({
    required DateTime start,
    required DateTime end,
    Category? category,
  }) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);

    final baseQuery = isar.isarExpenses.where().dateUtcBetween(
      startDay,
      endDay,
      includeLower: true,
      includeUpper: false,
    );

    if (category != null) {
      return baseQuery
          .filter()
          .categoryIndexEqualTo(category.index)
          .watch(fireImmediately: true)
          .map(_toDomain);
    }

    return baseQuery.watch(fireImmediately: true).map(_toDomain);
  }

  @override
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.isarExpenses.clear();
    });
  }

  List<Expense> _toDomain(List<IsarExpense> rows) {
    return rows
        .map((e) => e.toDomain())
        .toList()
      ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));
  }
}
