import '../../core/category.dart';

class Expense {
  final int? id;
  final int amountMinor;
  final Category category;
  final String? notes;
  final DateTime dateUtc;

  const Expense({
    this.id,
    required this.amountMinor,
    required this.category,
    required this.dateUtc,
    this.notes,
  });

  factory Expense.fromLocal({
    int? id,
    required int amountMinor,
    required Category category,
    required DateTime localDate,
    String? notes,
  }) {
    return Expense(
      id: id,
      amountMinor: amountMinor,
      category: category,
      dateUtc: localDate.toUtc(),
      notes: notes,
    );
  }

  DateTime get localDate => dateUtc.toLocal();
  bool get isIncome => category.isIncome;

  Expense copyWith({
    int? id,
    int? amountMinor,
    Category? category,
    String? notes,
    DateTime? dateUtc,
  }) {
    return Expense(
      id: id ?? this.id,
      amountMinor: amountMinor ?? this.amountMinor,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      dateUtc: dateUtc ?? this.dateUtc,
    );
  }
}
