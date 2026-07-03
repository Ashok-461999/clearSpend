import 'package:isar/isar.dart';

import '../../core/category.dart';
import '../../domain/models/emi.dart';

part 'isar_emi.g.dart';

@collection
class IsarEmi {
  Id id = Isar.autoIncrement;

  late String name;

  late int totalAmountMinor;

  late int monthlyAmountMinor;

  late int categoryIndex;

  late DateTime startDate;

  late int totalMonths;

  late int paidMonths;

  String? notes;

  IsarEmi();

  factory IsarEmi.fromDomain(Emi e) {
    final row = IsarEmi()
      ..name = e.name
      ..totalAmountMinor = e.totalAmountMinor
      ..monthlyAmountMinor = e.monthlyAmountMinor
      ..categoryIndex = e.category.index
      ..startDate = e.startDate
      ..totalMonths = e.totalMonths
      ..paidMonths = e.paidMonths
      ..notes = e.notes;
    if (e.id != null) row.id = e.id!;
    return row;
  }

  Emi toDomain() => Emi(
        id: id,
        name: name,
        totalAmountMinor: totalAmountMinor,
        monthlyAmountMinor: monthlyAmountMinor,
        category: Category.values[categoryIndex],
        startDate: startDate,
        totalMonths: totalMonths,
        paidMonths: paidMonths,
        notes: notes,
      );
}
