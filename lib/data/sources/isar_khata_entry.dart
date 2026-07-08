import 'package:isar/isar.dart';

import '../../domain/models/khata_entry.dart';

part 'isar_khata_entry.g.dart';

@collection
class IsarKhataEntry {
  Id id = Isar.autoIncrement;

  late String personName;

  String? phone;

  late int amountMinor;

  late int typeIndex;

  @Index()
  late DateTime dateUtc;

  DateTime? dueDate;

  String? notes;

  IsarKhataEntry();

  factory IsarKhataEntry.fromDomain(KhataEntry e) {
    final row = IsarKhataEntry()
      ..personName = e.personName
      ..phone = e.phone
      ..amountMinor = e.amountMinor
      ..typeIndex = e.type.index
      ..dateUtc = e.dateUtc
      ..dueDate = e.dueDate
      ..notes = e.notes;
    if (e.id != null) row.id = e.id!;
    return row;
  }

  KhataEntry toDomain() => KhataEntry(
        id: id,
        personName: personName,
        phone: phone,
        amountMinor: amountMinor,
        type: EntryType.values[typeIndex],
        dateUtc: dateUtc,
        dueDate: dueDate,
        notes: notes,
      );
}
