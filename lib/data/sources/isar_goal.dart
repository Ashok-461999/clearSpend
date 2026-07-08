import 'package:isar/isar.dart';

import '../../core/category.dart';
import '../../domain/models/goal.dart';

part 'isar_goal.g.dart';

@collection
class IsarGoal {
  Id id = Isar.autoIncrement;

  late String name;

  late int targetAmount;

  late int currentAmount;

  late DateTime deadline;

  int? categoryIndex;

  IsarGoal();

  factory IsarGoal.fromDomain(Goal g) {
    final row = IsarGoal()
      ..name = g.name
      ..targetAmount = g.targetAmount
      ..currentAmount = g.currentAmount
      ..deadline = g.deadline
      ..categoryIndex = g.category?.index;
    if (g.id != null) row.id = g.id!;
    return row;
  }

  Goal toDomain() => Goal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
        category: categoryIndex != null ? Category.values[categoryIndex!] : null,
      );
}
