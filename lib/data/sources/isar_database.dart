import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'isar_emi.dart';
import 'isar_expense.dart';

Future<Isar> openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [IsarExpenseSchema, IsarEmiSchema],
    directory: dir.path,
  );
}
