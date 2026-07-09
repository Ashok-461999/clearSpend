// LAYER: data (storage detail — the ONLY file that knows Isar's schema)
// RESPONSIBILITY: the Isar @collection persistence model + mapping to/from
// the domain Expense. Nothing outside the data layer imports this; the rest
// of the app sees only the domain Expense, so Isar types never leak upward.

import 'package:isar/isar.dart';

import '../../core/category.dart';
import '../../domain/models/expense.dart';

part 'isar_expense.g.dart';

@collection
class IsarExpense {
  Id id = Isar.autoIncrement;

  late int amountMinor;

  late int categoryIndex;

  String? notes;

  @Index()
  late DateTime dateUtc;

  bool isWaste = false;

  IsarExpense();

  factory IsarExpense.fromDomain(Expense e) {
    final row = IsarExpense()
      ..amountMinor = e.amountMinor
      ..categoryIndex = e.category.index
      ..notes = e.notes
      ..dateUtc = e.dateUtc
      ..isWaste = e.isWaste;
    if (e.id != null) row.id = e.id!;
    return row;
  }

  Expense toDomain() => Expense(
        id: id,
        amountMinor: amountMinor,
        category: Category.values[categoryIndex],
        notes: notes,
        dateUtc: dateUtc,
        isWaste: isWaste,
      );
}
