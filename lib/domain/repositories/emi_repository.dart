import '../models/emi.dart';

abstract interface class EmiRepository {
  Future<int> save(Emi emi);
  Future<void> delete(int id);
  Stream<List<Emi>> watchAll();

  /// Deletes all EMI records.
  Future<void> clearAll();
}
