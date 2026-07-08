import '../../core/money.dart';

enum TradeType { equity, futures, options, crypto }

extension TradeTypeX on TradeType {
  String get label {
    switch (this) {
      case TradeType.equity: return 'Equity';
      case TradeType.futures: return 'Futures';
      case TradeType.options: return 'Options';
      case TradeType.crypto: return 'Crypto';
    }
  }
}

enum TradeStatus { open, closed }

class Trade {
  final int? id;
  final String instrumentName;
  final TradeType tradeType;
  final int entryPrice; // paise per unit
  final double quantity;
  final int brokerage; // paise
  final DateTime entryDate;
  final DateTime? exitDate;
  final int? exitPrice; // paise per unit, null if open
  final TradeStatus status;

  const Trade({
    this.id,
    required this.instrumentName,
    required this.tradeType,
    required this.entryPrice,
    required this.quantity,
    this.brokerage = 0,
    required this.entryDate,
    this.exitDate,
    this.exitPrice,
    this.status = TradeStatus.open,
  });

  int get netPnl {
    if (status == TradeStatus.open || exitPrice == null) return 0;
    final gross = ((exitPrice! - entryPrice) * quantity).round();
    return gross - brokerage;
  }

  bool get isProfitable => netPnl > 0;

  Trade copyWith({
    int? id,
    String? instrumentName,
    TradeType? tradeType,
    int? entryPrice,
    double? quantity,
    int? brokerage,
    DateTime? entryDate,
    DateTime? exitDate,
    int? exitPrice,
    TradeStatus? status,
    bool clearId = false,
  }) {
    return Trade(
      id: clearId ? null : (id ?? this.id),
      instrumentName: instrumentName ?? this.instrumentName,
      tradeType: tradeType ?? this.tradeType,
      entryPrice: entryPrice ?? this.entryPrice,
      quantity: quantity ?? this.quantity,
      brokerage: brokerage ?? this.brokerage,
      entryDate: entryDate ?? this.entryDate,
      exitDate: exitDate ?? this.exitDate,
      exitPrice: exitPrice ?? this.exitPrice,
      status: status ?? this.status,
    );
  }
}
