import 'package:isar/isar.dart';

import '../../core/category.dart';
import '../../domain/models/category_budget.dart';

part 'isar_category_budget.g.dart';

@collection
class IsarCategoryBudget {
  Id id = Isar.autoIncrement;

  late int categoryIndex;

  late int monthlyLimit;

  @Index()
  late int yearMonth;

  IsarCategoryBudget();

  factory IsarCategoryBudget.fromDomain(CategoryBudget b) {
    final row = IsarCategoryBudget()
      ..categoryIndex = b.category.index
      ..monthlyLimit = b.monthlyLimit
      ..yearMonth = b.yearMonth;
    if (b.id != null) row.id = b.id!;
    return row;
  }

  CategoryBudget toDomain() => CategoryBudget(
        id: id,
        category: Category.values[categoryIndex],
        monthlyLimit: monthlyLimit,
        yearMonth: yearMonth,
      );
}
