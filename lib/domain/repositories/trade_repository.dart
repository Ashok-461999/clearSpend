import '../models/trade.dart';

abstract class TradeRepository {
  Future<int> save(Trade trade);
  Future<void> delete(int id);
  Stream<List<Trade>> watchAll();
  Future<void> clearAll();
}
