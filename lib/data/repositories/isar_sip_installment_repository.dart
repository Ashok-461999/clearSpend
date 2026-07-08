import 'package:isar/isar.dart';

import '../../domain/models/sip_installment.dart';
import '../../domain/repositories/sip_installment_repository.dart';
import '../sources/isar_sip_installment.dart';

class IsarSipInstallmentRepository implements SipInstallmentRepository {
  final Isar isar;

  IsarSipInstallmentRepository(this.isar);

  @override
  Future<int> save(SipInstallment installment) async {
    final row = IsarSipInstallment.fromDomain(installment);
    await isar.writeTxn(() => isar.isarSipInstallments.put(row));
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.isarSipInstallments.delete(id));
  }

  @override
  Future<List<SipInstallment>> getForInvestment(int investmentId) async {
    final rows = await isar.isarSipInstallments
        .where()
        .investmentIdEqualTo(investmentId)
        .findAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<SipInstallment>> watchForInvestment(int investmentId) {
    return isar.isarSipInstallments
        .where()
        .investmentIdEqualTo(investmentId)
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
