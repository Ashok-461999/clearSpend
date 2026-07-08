import 'package:isar/isar.dart';

import '../../domain/models/investment.dart';

part 'isar_investment.g.dart';

@collection
class IsarInvestment {
  Id id = Isar.autoIncrement;

  late int assetTypeIndex;

  late String name;

  String? folioNumber;

  late double units;

  late int buyPricePerUnit;

  late int currentPricePerUnit;

  late DateTime investedDate;

  DateTime? maturityDate;

  double? interestRate;

  late bool isSip;

  int? sipAmount;

  String? sipFrequency;

  DateTime? sipStartDate;

  DateTime? sipEndDate;

  DateTime? lastUpdatedAt;

  IsarInvestment();

  factory IsarInvestment.fromDomain(Investment inv) {
    final row = IsarInvestment()
      ..assetTypeIndex = inv.assetType.index
      ..name = inv.name
      ..folioNumber = inv.folioNumber
      ..units = inv.units
      ..buyPricePerUnit = inv.buyPricePerUnit
      ..currentPricePerUnit = inv.currentPricePerUnit
      ..investedDate = inv.investedDate
      ..maturityDate = inv.maturityDate
      ..interestRate = inv.interestRate
      ..isSip = inv.isSip
      ..sipAmount = inv.sipAmount
      ..sipFrequency = inv.sipFrequency
      ..sipStartDate = inv.sipStartDate
      ..sipEndDate = inv.sipEndDate
      ..lastUpdatedAt = inv.lastUpdatedAt;
    if (inv.id != null) row.id = inv.id!;
    return row;
  }

  Investment toDomain() => Investment(
        id: id,
        assetType: AssetType.values[assetTypeIndex],
        name: name,
        folioNumber: folioNumber,
        units: units,
        buyPricePerUnit: buyPricePerUnit,
        currentPricePerUnit: currentPricePerUnit,
        investedDate: investedDate,
        maturityDate: maturityDate,
        interestRate: interestRate,
        isSip: isSip,
        sipAmount: sipAmount,
        sipFrequency: sipFrequency,
        sipStartDate: sipStartDate,
        sipEndDate: sipEndDate,
        lastUpdatedAt: lastUpdatedAt,
      );
}
