// LAYER: domain (pure Dart — no Isar, no Flutter)
// RESPONSIBILITY: the SWAP SEAM. application/ and presentation/ depend on
// THIS interface, never on Isar. To go cloud/API later: write a class that
// implements this, rebind one provider in application/providers.dart, and
// nothing above the data layer changes.

import '../../core/category.dart';
import '../models/expense.dart';

abstract interface class ExpenseRepository {
  /// Insert (id == null) or update (id != null). Returns the persisted id.
  Future<int> save(Expense expense);

  Future<void> delete(int id);

  /// Reactive stream of expenses whose LOCAL date falls in [start, end).
  /// [end] is EXCLUSIVE. Optional [category] filter. Newest first.
  /// Emits a fresh list on every relevant write — the UI just listens.
  Stream<List<Expense>> watchInRange({
    required DateTime start,
    required DateTime end,
    Category? category,
  });

  /// Deletes all expense records.
  Future<void> clearAll();
}
