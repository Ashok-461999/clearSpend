import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';

import '../../data/sources/isar_category_budget.dart';
import '../../data/sources/isar_emi.dart';
import '../../data/sources/isar_expense.dart';
import '../../data/sources/isar_goal.dart';
import '../../data/sources/isar_investment.dart';
import '../../data/sources/isar_khata_entry.dart';
import '../../data/sources/isar_sip_installment.dart';
import '../../data/sources/isar_trade.dart';

class BackupService {
  static Future<String?> exportToJson(Isar isar) async {
    try {
      final expenses = await isar.isarExpenses.where().findAll();
      final emis = await isar.isarEmis.where().findAll();
      final khata = await isar.isarKhataEntrys.where().findAll();
      final trades = await isar.isarTrades.where().findAll();
      final budgets = await isar.isarCategoryBudgets.where().findAll();
      final goals = await isar.isarGoals.where().findAll();
      final investments = await isar.isarInvestments.where().findAll();
      final sipInstallments = await isar.isarSipInstallments.where().findAll();

      final data = {
        'version': 1,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'expenses': expenses.map(_expenseToMap).toList(),
        'emis': emis.map(_emiToMap).toList(),
        'khataEntries': khata.map(_khataToMap).toList(),
        'trades': trades.map(_tradeToMap).toList(),
        'categoryBudgets': budgets.map(_budgetToMap).toList(),
        'goals': goals.map(_goalToMap).toList(),
        'investments': investments.map(_investmentToMap).toList(),
        'sipInstallments': sipInstallments.map(_sipToMap).toList(),
      };

      final json = const JsonEncoder.withIndent('  ').convert(data);

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export ClearSpend Backup',
        fileName: 'fintrack_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return null;

      await File(result).writeAsString(json);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> importFromJson(Isar isar, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    }

    final jsonStr = await file.readAsString();
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final expenses = (data['expenses'] as List).map((e) => _mapToExpense(e as Map<String, dynamic>)).toList();
    final emis = (data['emis'] as List).map((e) => _mapToEmi(e as Map<String, dynamic>)).toList();
    final khata = (data['khataEntries'] as List).map((e) => _mapToKhata(e as Map<String, dynamic>)).toList();
    final trades = (data['trades'] as List).map((e) => _mapToTrade(e as Map<String, dynamic>)).toList();
    final budgets = (data['categoryBudgets'] as List).map((e) => _mapToBudget(e as Map<String, dynamic>)).toList();
    final goals = (data['goals'] as List).map((e) => _mapToGoal(e as Map<String, dynamic>)).toList();
    final investments = (data['investments'] as List).map((e) => _mapToInvestment(e as Map<String, dynamic>)).toList();
    final sipInstallments = (data['sipInstallments'] as List).map((e) => _mapToSip(e as Map<String, dynamic>)).toList();

    await isar.writeTxn(() async {
      await isar.isarExpenses.clear();
      await isar.isarEmis.clear();
      await isar.isarKhataEntrys.clear();
      await isar.isarTrades.clear();
      await isar.isarCategoryBudgets.clear();
      await isar.isarGoals.clear();
      await isar.isarInvestments.clear();
      await isar.isarSipInstallments.clear();

      if (expenses.isNotEmpty) await isar.isarExpenses.putAll(expenses);
      if (emis.isNotEmpty) await isar.isarEmis.putAll(emis);
      if (khata.isNotEmpty) await isar.isarKhataEntrys.putAll(khata);
      if (trades.isNotEmpty) await isar.isarTrades.putAll(trades);
      if (budgets.isNotEmpty) await isar.isarCategoryBudgets.putAll(budgets);
      if (goals.isNotEmpty) await isar.isarGoals.putAll(goals);
      if (investments.isNotEmpty) await isar.isarInvestments.putAll(investments);
      if (sipInstallments.isNotEmpty) await isar.isarSipInstallments.putAll(sipInstallments);
    });

    return expenses.length +
        emis.length +
        khata.length +
        trades.length +
        budgets.length +
        goals.length +
        investments.length +
        sipInstallments.length;
  }

  static Future<void> clearAllData(Isar isar) async {
    await isar.writeTxn(() async {
      await isar.isarExpenses.clear();
      await isar.isarEmis.clear();
      await isar.isarKhataEntrys.clear();
      await isar.isarTrades.clear();
      await isar.isarCategoryBudgets.clear();
      await isar.isarGoals.clear();
      await isar.isarInvestments.clear();
      await isar.isarSipInstallments.clear();
    });
  }

  // ── Serialization helpers ──

  static Map<String, dynamic> _expenseToMap(IsarExpense e) {
    return {
      'amountMinor': e.amountMinor,
      'categoryIndex': e.categoryIndex,
      'notes': e.notes,
      'dateUtc': e.dateUtc.toIso8601String(),
      'isWaste': e.isWaste,
    };
  }

  static IsarExpense _mapToExpense(Map<String, dynamic> m) {
    return IsarExpense()
      ..amountMinor = m['amountMinor'] as int
      ..categoryIndex = m['categoryIndex'] as int
      ..notes = m['notes'] as String?
      ..dateUtc = DateTime.parse(m['dateUtc'] as String)
      ..isWaste = m['isWaste'] as bool? ?? false;
  }

  static Map<String, dynamic> _emiToMap(IsarEmi e) {
    return {
      'name': e.name,
      'totalAmountMinor': e.totalAmountMinor,
      'monthlyAmountMinor': e.monthlyAmountMinor,
      'categoryIndex': e.categoryIndex,
      'startDate': e.startDate.toIso8601String(),
      'totalMonths': e.totalMonths,
      'paidMonths': e.paidMonths,
      'notes': e.notes,
    };
  }

  static IsarEmi _mapToEmi(Map<String, dynamic> m) {
    return IsarEmi()
      ..name = m['name'] as String
      ..totalAmountMinor = m['totalAmountMinor'] as int
      ..monthlyAmountMinor = m['monthlyAmountMinor'] as int
      ..categoryIndex = m['categoryIndex'] as int
      ..startDate = DateTime.parse(m['startDate'] as String)
      ..totalMonths = m['totalMonths'] as int
      ..paidMonths = m['paidMonths'] as int
      ..notes = m['notes'] as String?;
  }

  static Map<String, dynamic> _khataToMap(IsarKhataEntry e) {
    return {
      'personName': e.personName,
      'phone': e.phone,
      'amountMinor': e.amountMinor,
      'typeIndex': e.typeIndex,
      'dateUtc': e.dateUtc.toIso8601String(),
      'dueDate': e.dueDate?.toIso8601String(),
      'notes': e.notes,
    };
  }

  static IsarKhataEntry _mapToKhata(Map<String, dynamic> m) {
    return IsarKhataEntry()
      ..personName = m['personName'] as String
      ..phone = m['phone'] as String?
      ..amountMinor = m['amountMinor'] as int
      ..typeIndex = m['typeIndex'] as int
      ..dateUtc = DateTime.parse(m['dateUtc'] as String)
      ..dueDate = m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null
      ..notes = m['notes'] as String?;
  }

  static Map<String, dynamic> _tradeToMap(IsarTrade e) {
    return {
      'instrumentName': e.instrumentName,
      'tradeTypeIndex': e.tradeTypeIndex,
      'entryPrice': e.entryPrice,
      'quantity': e.quantity,
      'brokerage': e.brokerage,
      'entryDate': e.entryDate.toIso8601String(),
      'exitDate': e.exitDate?.toIso8601String(),
      'exitPrice': e.exitPrice,
      'statusIndex': e.statusIndex,
    };
  }

  static IsarTrade _mapToTrade(Map<String, dynamic> m) {
    return IsarTrade()
      ..instrumentName = m['instrumentName'] as String
      ..tradeTypeIndex = m['tradeTypeIndex'] as int
      ..entryPrice = m['entryPrice'] as int
      ..quantity = (m['quantity'] as num).toDouble()
      ..brokerage = m['brokerage'] as int
      ..entryDate = DateTime.parse(m['entryDate'] as String)
      ..exitDate = m['exitDate'] != null ? DateTime.parse(m['exitDate'] as String) : null
      ..exitPrice = m['exitPrice'] as int?
      ..statusIndex = m['statusIndex'] as int;
  }

  static Map<String, dynamic> _budgetToMap(IsarCategoryBudget e) {
    return {
      'categoryIndex': e.categoryIndex,
      'monthlyLimit': e.monthlyLimit,
      'yearMonth': e.yearMonth,
    };
  }

  static IsarCategoryBudget _mapToBudget(Map<String, dynamic> m) {
    return IsarCategoryBudget()
      ..categoryIndex = m['categoryIndex'] as int
      ..monthlyLimit = m['monthlyLimit'] as int
      ..yearMonth = m['yearMonth'] as int;
  }

  static Map<String, dynamic> _goalToMap(IsarGoal e) {
    return {
      'name': e.name,
      'targetAmount': e.targetAmount,
      'currentAmount': e.currentAmount,
      'deadline': e.deadline.toIso8601String(),
      'categoryIndex': e.categoryIndex,
    };
  }

  static IsarGoal _mapToGoal(Map<String, dynamic> m) {
    return IsarGoal()
      ..name = m['name'] as String
      ..targetAmount = m['targetAmount'] as int
      ..currentAmount = m['currentAmount'] as int
      ..deadline = DateTime.parse(m['deadline'] as String)
      ..categoryIndex = m['categoryIndex'] as int;
  }

  static Map<String, dynamic> _investmentToMap(IsarInvestment e) {
    return {
      'assetTypeIndex': e.assetTypeIndex,
      'name': e.name,
      'folioNumber': e.folioNumber,
      'units': e.units,
      'buyPricePerUnit': e.buyPricePerUnit,
      'currentPricePerUnit': e.currentPricePerUnit,
      'investedDate': e.investedDate.toIso8601String(),
      'maturityDate': e.maturityDate?.toIso8601String(),
      'interestRate': e.interestRate,
      'isSip': e.isSip,
      'sipAmount': e.sipAmount,
      'sipFrequency': e.sipFrequency,
      'sipStartDate': e.sipStartDate?.toIso8601String(),
      'sipEndDate': e.sipEndDate?.toIso8601String(),
      'lastUpdatedAt': e.lastUpdatedAt?.toIso8601String(),
    };
  }

  static IsarInvestment _mapToInvestment(Map<String, dynamic> m) {
    return IsarInvestment()
      ..assetTypeIndex = m['assetTypeIndex'] as int
      ..name = m['name'] as String
      ..folioNumber = m['folioNumber'] as String?
      ..units = (m['units'] as num).toDouble()
      ..buyPricePerUnit = m['buyPricePerUnit'] as int
      ..currentPricePerUnit = m['currentPricePerUnit'] as int
      ..investedDate = DateTime.parse(m['investedDate'] as String)
      ..maturityDate = m['maturityDate'] != null ? DateTime.parse(m['maturityDate'] as String) : null
      ..interestRate = m['interestRate'] as double?
      ..isSip = m['isSip'] as bool
      ..sipAmount = m['sipAmount'] as int?
      ..sipFrequency = m['sipFrequency'] as String?
      ..sipStartDate = m['sipStartDate'] != null ? DateTime.parse(m['sipStartDate'] as String) : null
      ..sipEndDate = m['sipEndDate'] != null ? DateTime.parse(m['sipEndDate'] as String) : null
      ..lastUpdatedAt = m['lastUpdatedAt'] != null ? DateTime.parse(m['lastUpdatedAt'] as String) : null;
  }

  static Map<String, dynamic> _sipToMap(IsarSipInstallment e) {
    return {
      'investmentId': e.investmentId,
      'amount': e.amount,
      'date': e.date.toIso8601String(),
      'nav': e.nav,
      'unitsAllotted': e.unitsAllotted,
    };
  }

  static IsarSipInstallment _mapToSip(Map<String, dynamic> m) {
    return IsarSipInstallment()
      ..investmentId = m['investmentId'] as int
      ..amount = m['amount'] as int
      ..date = DateTime.parse(m['date'] as String)
      ..nav = m['nav'] as double?
      ..unitsAllotted = m['unitsAllotted'] as double?;
  }
}
