enum CoinReason {
  dailyLogin,
  loginStreak,
  transactionAdded,
  budgetStreak,
  budgetStreak7,
  budgetStreak30,
}

class CoinTransaction {
  final DateTime timestamp;
  final int amount;
  final CoinReason reason;
  final String label;

  const CoinTransaction({
    required this.timestamp,
    required this.amount,
    required this.reason,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'amount': amount,
        'reason': reason.index,
        'label': label,
      };

  factory CoinTransaction.fromJson(Map<String, dynamic> json) => CoinTransaction(
        timestamp: DateTime.parse(json['timestamp'] as String),
        amount: json['amount'] as int,
        reason: CoinReason.values[json['reason'] as int],
        label: json['label'] as String,
      );
}
