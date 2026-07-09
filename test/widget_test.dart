import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moneymate/app.dart';
import 'package:moneymate/application/providers.dart';
import 'package:moneymate/core/category.dart';
import 'package:moneymate/domain/models/expense.dart';
import 'package:moneymate/domain/repositories/expense_repository.dart';

class _MockExpenseRepository implements ExpenseRepository {
  @override
  Future<int> save(Expense expense) async => 1;

  @override
  Future<void> delete(int id) async {}

  @override
  Stream<List<Expense>> watchInRange({
    required DateTime start,
    required DateTime end,
    Category? category,
  }) {
    return Stream.value([]);
  }
  
  @override
  Future<void> clearAll() {
    // TODO: implement clearAll
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseRepositoryProvider.overrideWithValue(_MockExpenseRepository()),
        ],
        child: const ClearSpendApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
