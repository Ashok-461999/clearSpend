import 'package:isar/isar.dart';

import '../../domain/models/category_budget.dart';
import '../../domain/repositories/category_budget_repository.dart';
import '../sources/isar_category_budget.dart';

class IsarCategoryBudgetRepository implements CategoryBudgetRepository {
  final Isar isar;

  IsarCategoryBudgetRepository(this.isar);

  @override
  Future<int> save(CategoryBudget budget) async {
    final row = IsarCategoryBudget.fromDomain(budget);
    await isar.writeTxn(() => isar.isarCategoryBudgets.put(row));
    return row.id;
  }

  @override
  Future<void> delete(int id) async {
    await isar.writeTxn(() => isar.isarCategoryBudgets.delete(id));
  }

  @override
  Future<List<CategoryBudget>> getForMonth(int yearMonth) async {
    final rows = await isar.isarCategoryBudgets
        .where()
        .yearMonthEqualTo(yearMonth)
        .findAll();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Stream<List<CategoryBudget>> watchAll() {
    return isar.isarCategoryBudgets
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
