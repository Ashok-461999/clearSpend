class SipInstallment {
  final int? id;
  final int investmentId;
  final int amount; // paise
  final DateTime date;
  final double? nav;
  final double? unitsAllotted;

  const SipInstallment({
    this.id,
    required this.investmentId,
    required this.amount,
    required this.date,
    this.nav,
    this.unitsAllotted,
  });

  SipInstallment copyWith({
    int? id,
    int? investmentId,
    int? amount,
    DateTime? date,
    double? nav,
    double? unitsAllotted,
    bool clearId = false,
  }) {
    return SipInstallment(
      id: clearId ? null : (id ?? this.id),
      investmentId: investmentId ?? this.investmentId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      nav: nav ?? this.nav,
      unitsAllotted: unitsAllotted ?? this.unitsAllotted,
    );
  }
}
