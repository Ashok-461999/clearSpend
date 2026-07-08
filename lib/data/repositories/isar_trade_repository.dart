import 'package:isar/isar.dart';

import '../../domain/models/trade.dart';
import '../../domain/repositories/trade_repository.dart';
import '../sources/isar_trade.dart';

class IsarTradeRepository implements TradeRepository {
  final Isar isar;

  IsarTradeRepository(this.isar);

  @override
  Future<int> save(Trade trade) async {
    final row = IsarTrade.fromDomain(trade);
    await isar.writeTxn(() async {
      await isar.isarTrades.put(row);
    });
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.isarTrades.delete(id);
    });
  }

  @override
  Stream<List<Trade>> watchAll() {
    return isar.isarTrades.where().watch(fireImmediately: true).map(
          (rows) => rows.map((r) => r.toDomain()).toList()
            ..sort((a, b) => b.entryDate.compareTo(a.entryDate)),
        );
  }

  @override
  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.isarTrades.clear();
    });
  }
}
