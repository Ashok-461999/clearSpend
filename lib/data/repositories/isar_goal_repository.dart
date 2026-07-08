import 'package:isar/isar.dart';

import '../../domain/models/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../sources/isar_goal.dart';

class IsarGoalRepository implements GoalRepository {
  final Isar isar;

  IsarGoalRepository(this.isar);

  @override
  Future<int> save(Goal goal) async {
    final row = IsarGoal.fromDomain(goal);
    await isar.writeTxn(() => isar.isarGoals.put(row));
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.isarGoals.delete(id));
  }

  @override
  Stream<List<Goal>> watchAll() {
    return isar.isarGoals
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
