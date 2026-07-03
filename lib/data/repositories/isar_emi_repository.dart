import 'package:isar/isar.dart';

import '../../domain/models/emi.dart';
import '../../domain/repositories/emi_repository.dart';
import '../sources/isar_emi.dart';

class IsarEmiRepository implements EmiRepository {
  final Isar isar;
  final bool _available;

  IsarEmiRepository(this.isar) : _available = _checkAvailable(isar);

  static bool _checkAvailable(Isar isar) {
    try {
      isar.isarEmis;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<int> save(Emi emi) async {
    if (!_available) return -1;
    final row = IsarEmi.fromDomain(emi);
    await isar.writeTxn(() async {
      await isar.isarEmis.put(row);
    });
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    if (!_available) return;
    await isar.writeTxn(() async {
      await isar.isarEmis.delete(id);
    });
  }

  @override
  Future<void> clearAll() async {
    if (!_available) return;
    await isar.writeTxn(() async {
      await isar.isarEmis.clear();
    });
  }

  @override
  Stream<List<Emi>> watchAll() {
    if (!_available) return Stream.value([]);
    return isar.isarEmis.where().watch(fireImmediately: true).map(
      (rows) {
        return rows.map((e) => e.toDomain()).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
      },
    );
  }
}
