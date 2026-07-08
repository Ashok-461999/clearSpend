import '../../core/money.dart';

enum AssetType {
  stocks, mutualFund, sip, gold, fd, ppf, nps, crypto, bonds, other
}

extension AssetTypeX on AssetType {
  String get label {
    switch (this) {
      case AssetType.stocks: return 'Stocks';
      case AssetType.mutualFund: return 'Mutual Fund';
      case AssetType.sip: return 'SIP';
      case AssetType.gold: return 'Gold';
      case AssetType.fd: return 'Fixed Deposit';
      case AssetType.ppf: return 'PPF';
      case AssetType.nps: return 'NPS';
      case AssetType.crypto: return 'Crypto';
      case AssetType.bonds: return 'Bonds';
      case AssetType.other: return 'Other';
    }
  }

  bool get isFixedIncome => this == AssetType.fd || this == AssetType.ppf || this == AssetType.bonds;
  bool get isMarketLinked => this == AssetType.stocks || this == AssetType.mutualFund || this == AssetType.sip || this == AssetType.crypto;
  bool get hasMaturity => isFixedIncome;
}

class Investment {
  final int? id;
  final AssetType assetType;
  final String name;
  final String? folioNumber;
  final double units;
  final int buyPricePerUnit;
  final int currentPricePerUnit;
  final DateTime investedDate;
  final DateTime? maturityDate;
  final double? interestRate;
  final bool isSip;
  final int? sipAmount;
  final String? sipFrequency;
  final DateTime? sipStartDate;
  final DateTime? sipEndDate;
  final DateTime? lastUpdatedAt;

  const Investment({
    this.id,
    required this.assetType,
    required this.name,
    this.folioNumber,
    this.units = 0,
    required this.buyPricePerUnit,
    required this.currentPricePerUnit,
    required this.investedDate,
    this.maturityDate,
    this.interestRate,
    this.isSip = false,
    this.sipAmount,
    this.sipFrequency,
    this.sipStartDate,
    this.sipEndDate,
    this.lastUpdatedAt,
  });

  int get totalInvested => (buyPricePerUnit * units).round();
  int get currentValue => (currentPricePerUnit * units).round();
  int get absoluteGain => currentValue - totalInvested;
  double get gainPercent => totalInvested > 0 ? (absoluteGain / totalInvested) * 100 : 0;
  bool get isProfitable => absoluteGain >= 0;

  int? get expectedMaturityValue {
    if (!assetType.hasMaturity || maturityDate == null || interestRate == null) return null;
    final years = maturityDate!.difference(investedDate).inDays / 365.0;
    if (years <= 0) return null;
    final rate = interestRate! / 100;
    // Simple interest for FD/short term, compound for long term
    if (assetType == AssetType.fd) {
      return (totalInvested * (1 + rate * years)).round();
    }
    return (totalInvested * _pow(1 + rate, years)).round();
  }

  int get daysToMaturity {
    if (maturityDate == null) return 0;
    return maturityDate!.difference(DateTime.now()).inDays.clamp(0, 99999);
  }

  Investment copyWith({
    int? id,
    AssetType? assetType,
    String? name,
    String? folioNumber,
    double? units,
    int? buyPricePerUnit,
    int? currentPricePerUnit,
    DateTime? investedDate,
    DateTime? maturityDate,
    double? interestRate,
    bool? isSip,
    int? sipAmount,
    String? sipFrequency,
    DateTime? sipStartDate,
    DateTime? sipEndDate,
    DateTime? lastUpdatedAt,
    bool clearId = false,
  }) {
    return Investment(
      id: clearId ? null : (id ?? this.id),
      assetType: assetType ?? this.assetType,
      name: name ?? this.name,
      folioNumber: folioNumber ?? this.folioNumber,
      units: units ?? this.units,
      buyPricePerUnit: buyPricePerUnit ?? this.buyPricePerUnit,
      currentPricePerUnit: currentPricePerUnit ?? this.currentPricePerUnit,
      investedDate: investedDate ?? this.investedDate,
      maturityDate: maturityDate ?? this.maturityDate,
      interestRate: interestRate ?? this.interestRate,
      isSip: isSip ?? this.isSip,
      sipAmount: sipAmount ?? this.sipAmount,
      sipFrequency: sipFrequency ?? this.sipFrequency,
      sipStartDate: sipStartDate ?? this.sipStartDate,
      sipEndDate: sipEndDate ?? this.sipEndDate,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  static double _pow(double x, double y) {
    if (y == 0) return 1;
    double result = 1;
    for (int i = 0; i < y.toInt(); i++) {
      result *= x;
    }
    return result;
  }
}
