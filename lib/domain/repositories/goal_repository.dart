import '../models/goal.dart';

abstract class GoalRepository {
  Future<int> save(Goal goal);
  Future<void> delete(int id);
  Stream<List<Goal>> watchAll();
}
