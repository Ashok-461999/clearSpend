import '../models/investment.dart';

abstract class InvestmentRepository {
  Future<int> save(Investment investment);
  Future<void> delete(int id);
  Stream<List<Investment>> watchAll();
}
