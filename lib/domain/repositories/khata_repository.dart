import '../models/khata_entry.dart';

abstract interface class KhataRepository {
  Future<int> save(KhataEntry entry);
  Future<void> delete(int id);
  Stream<List<KhataEntry>> watchAll();
  Future<void> clearAll();
}
