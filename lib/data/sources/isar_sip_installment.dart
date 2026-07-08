import 'package:isar/isar.dart';

import '../../domain/models/sip_installment.dart';

part 'isar_sip_installment.g.dart';

@collection
class IsarSipInstallment {
  Id id = Isar.autoIncrement;

  @Index()
  late int investmentId;

  late int amount;

  late DateTime date;

  double? nav;

  double? unitsAllotted;

  IsarSipInstallment();

  factory IsarSipInstallment.fromDomain(SipInstallment si) {
    final row = IsarSipInstallment()
      ..investmentId = si.investmentId
      ..amount = si.amount
      ..date = si.date
      ..nav = si.nav
      ..unitsAllotted = si.unitsAllotted;
    if (si.id != null) row.id = si.id!;
    return row;
  }

  SipInstallment toDomain() => SipInstallment(
        id: id,
        investmentId: investmentId,
        amount: amount,
        date: date,
        nav: nav,
        unitsAllotted: unitsAllotted,
      );
}
