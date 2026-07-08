import 'package:isar/isar.dart';

import '../../domain/models/investment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../sources/isar_investment.dart';

class IsarInvestmentRepository implements InvestmentRepository {
  final Isar isar;

  IsarInvestmentRepository(this.isar);

  @override
  Future<int> save(Investment investment) async {
    final row = IsarInvestment.fromDomain(investment);
    await isar.writeTxn(() => isar.isarInvestments.put(row));
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.isarInvestments.delete(id));
  }

  @override
  Stream<List<Investment>> watchAll() {
    return isar.isarInvestments
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
