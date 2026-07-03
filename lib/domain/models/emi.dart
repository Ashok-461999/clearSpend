import '../../core/category.dart';
import '../../core/money.dart';

class Emi {
  final int? id;
  final String name;
  final int totalAmountMinor;
  final int monthlyAmountMinor;
  final Category category;
  final DateTime startDate;
  final int totalMonths;
  final int paidMonths;
  final String? notes;

  const Emi({
    this.id,
    required this.name,
    required this.totalAmountMinor,
    required this.monthlyAmountMinor,
    required this.category,
    required this.startDate,
    required this.totalMonths,
    this.paidMonths = 0,
    this.notes,
  });

  double get progress => totalMonths > 0 ? paidMonths / totalMonths : 0.0;
  int get remainingMonths => totalMonths - paidMonths;
  int get paidAmountMinor => monthlyAmountMinor * paidMonths;
  int get remainingAmountMinor => totalAmountMinor - paidAmountMinor;
  bool get isCompleted => paidMonths >= totalMonths;

  DateTime get nextDueDate {
    final totalMonthsFromStart = paidMonths;
    final targetYear = startDate.year +
        (startDate.month - 1 + totalMonthsFromStart) ~/ 12;
    final targetMonth =
        ((startDate.month - 1 + totalMonthsFromStart) % 12) + 1;
    final daysInTargetMonth =
        DateTime(targetYear, targetMonth + 1, 0).day;
    final safeDay =
        startDate.day > daysInTargetMonth ? daysInTargetMonth : startDate.day;
    return DateTime(targetYear, targetMonth, safeDay);
  }

  String get totalFormatted => Money.format(totalAmountMinor);
  String get monthlyFormatted => Money.format(monthlyAmountMinor);
  String get paidFormatted => Money.format(paidAmountMinor);
  String get remainingFormatted => Money.format(remainingAmountMinor);

  Emi copyWith({
    int? id,
    String? name,
    int? totalAmountMinor,
    int? monthlyAmountMinor,
    Category? category,
    DateTime? startDate,
    int? totalMonths,
    int? paidMonths,
    String? notes,
    bool clearId = false,
  }) {
    return Emi(
      id: clearId ? null : (id ?? this.id),
      name: name ?? this.name,
      totalAmountMinor: totalAmountMinor ?? this.totalAmountMinor,
      monthlyAmountMinor: monthlyAmountMinor ?? this.monthlyAmountMinor,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      totalMonths: totalMonths ?? this.totalMonths,
      paidMonths: paidMonths ?? this.paidMonths,
      notes: notes ?? this.notes,
    );
  }
}
