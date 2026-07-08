import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_category_budget.dart';
import 'isar_emi.dart';
import 'isar_expense.dart';
import 'isar_goal.dart';
import 'isar_investment.dart';
import 'isar_khata_entry.dart';
import 'isar_sip_installment.dart';
import 'isar_trade.dart';

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      IsarExpenseSchema,
      IsarEmiSchema,
      IsarKhataEntrySchema,
      IsarTradeSchema,
      IsarCategoryBudgetSchema,
      IsarGoalSchema,
      IsarInvestmentSchema,
      IsarSipInstallmentSchema,
    ],
    directory: dir.path,
  );
}
