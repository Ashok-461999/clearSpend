import 'package:isar/isar.dart';

import '../../domain/models/khata_entry.dart';
import '../../domain/repositories/khata_repository.dart';
import '../sources/isar_khata_entry.dart';

class IsarKhataRepository implements KhataRepository {
  final Isar isar;
  final bool _available;

  IsarKhataRepository(this.isar) : _available = _checkAvailable(isar);

  static bool _checkAvailable(Isar isar) {
    try {
      isar.isarKhataEntrys;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> save(KhataEntry entry) async {
    if (!_available) return -1;
    final row = IsarKhataEntry.fromDomain(entry);
    await isar.writeTxn(() async {
      await isar.isarKhataEntrys.put(row);
    });
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    if (!_available) return;
    await isar.writeTxn(() async {
      await isar.isarKhataEntrys.delete(id);
    });
  }

  @override
  Future<void> clearAll() async {
    if (!_available) return;
    await isar.writeTxn(() async {
      await isar.isarKhataEntrys.clear();
    });
  }

  @override
  Stream<List<KhataEntry>> watchAll() {
    if (!_available) return Stream.value([]);
    return isar.isarKhataEntrys.where().watch(fireImmediately: true).map(
      (rows) {
        return rows.map((e) => e.toDomain()).toList()
          ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));
      },
    );
  }
}
