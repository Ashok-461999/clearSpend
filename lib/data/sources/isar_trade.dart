import 'package:isar/isar.dart';

import '../../domain/models/trade.dart';

part 'isar_trade.g.dart';

@collection
class IsarTrade {
  Id id = Isar.autoIncrement;

  late String instrumentName;

  late int tradeTypeIndex;

  late int entryPrice;

  late double quantity;

  late int brokerage;

  late DateTime entryDate;

  DateTime? exitDate;

  int? exitPrice;

  late int statusIndex;

  IsarTrade();

  factory IsarTrade.fromDomain(Trade t) {
    final row = IsarTrade()
      ..instrumentName = t.instrumentName
      ..tradeTypeIndex = t.tradeType.index
      ..entryPrice = t.entryPrice
      ..quantity = t.quantity
      ..brokerage = t.brokerage
      ..entryDate = t.entryDate
      ..exitDate = t.exitDate
      ..exitPrice = t.exitPrice
      ..statusIndex = t.status.index;
    if (t.id != null) row.id = t.id!;
    return row;
  }

  Trade toDomain() => Trade(
        id: id,
        instrumentName: instrumentName,
        tradeType: TradeType.values[tradeTypeIndex],
        entryPrice: entryPrice,
        quantity: quantity,
        brokerage: brokerage,
        entryDate: entryDate,
        exitDate: exitDate,
        exitPrice: exitPrice,
        status: TradeStatus.values[statusIndex],
      );
}
