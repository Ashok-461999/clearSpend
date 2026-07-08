import '../models/category_budget.dart';

abstract class CategoryBudgetRepository {
  Future<int> save(CategoryBudget budget);
  Future<void> delete(int id);
  Future<List<CategoryBudget>> getForMonth(int yearMonth);
  Stream<List<CategoryBudget>> watchAll();
}
