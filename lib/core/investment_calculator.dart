import 'dart:math';

class InvestmentCalculator {
  InvestmentCalculator._();

  static const double _xirrTolerance = 1e-7;
  static const int _xirrMaxIterations = 1000;

  static int simpleInterest(int principal, double ratePercent, double years) {
    return (principal * (1 + (ratePercent / 100) * years)).round();
  }

  static int compoundInterest(int principal, double ratePercent, double years, {int compoundingsPerYear = 1}) {
    final rate = ratePercent / 100;
    return (principal * pow(1 + rate / compoundingsPerYear, compoundingsPerYear * years)).round();
  }

  static int expectedMaturityValue(
    int principal,
    double ratePercent,
    DateTime startDate,
    DateTime maturityDate, {
    AssetInterestType type = AssetInterestType.simple,
  }) {
    final years = maturityDate.difference(startDate).inDays / 365.0;
    if (years <= 0) return principal;
    switch (type) {
      case AssetInterestType.simple:
        return simpleInterest(principal, ratePercent, years);
      case AssetInterestType.compoundedAnnually:
        return compoundInterest(principal, ratePercent, years);
      case AssetInterestType.compoundedMonthly:
        return compoundInterest(principal, ratePercent, years, compoundingsPerYear: 12);
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static String daysRemainingText(int days) {
    if (days <= 0) return 'Matured';
    if (days <= 1) return '1 day remaining';
    if (days <= 30) return '$days days remaining';
    final months = (days / 30).round();
    if (months <= 12) return '$months months remaining';
    final years = (days / 365).round();
    return '$years years remaining';
  }

  static String? maturityAlert(int days) {
    if (days <= 0) return 'matured';
    if (days == 1) return 'due tomorrow';
    if (days == 7) return 'due in 7 days';
    if (days == 30) return 'due in 30 days';
    return null;
  }

  static double xirr(List<double> cashFlows, List<DateTime> dates) {
    if (cashFlows.length != dates.length || cashFlows.isEmpty) return 0;

    double guess = 0.1;
    for (int i = 0; i < _xirrMaxIterations; i++) {
      final result = _xirrNewtonStep(cashFlows, dates, guess);
      final newGuess = guess - result.f / result.df;
      if ((newGuess - guess).abs() < _xirrTolerance) return newGuess;
      guess = newGuess;
    }
    return guess;
  }

  static _XirrResult _xirrNewtonStep(List<double> cashFlows, List<DateTime> dates, double rate) {
    final firstDate = dates.first;
    double f = 0;
    double df = 0;
    for (int i = 0; i < cashFlows.length; i++) {
      final daysDiff = dates[i].difference(firstDate).inDays / 365.0;
      final exp = pow(1 + rate, daysDiff);
      f += cashFlows[i] / exp;
      df -= cashFlows[i] * daysDiff / (exp * (1 + rate));
    }
    return _XirrResult(f, df);
  }

  static double xirrForInvestment(int totalInvested, int currentValue, DateTime startDate, {DateTime? endDate}) {
    final end = endDate ?? DateTime.now();
    final flows = [-totalInvested.toDouble(), currentValue.toDouble()];
    final dates = [startDate, end];
    return xirr(flows, dates) * 100;
  }

  static double xirrForSip(List<int> installments, List<DateTime> dates, int currentValue) {
    final flows = installments.map((i) => -i.toDouble()).toList();
    flows.add(currentValue.toDouble());
    dates.add(DateTime.now());
    return xirr(flows, dates) * 100;
  }
}

class _XirrResult {
  final double f;
  final double df;
  const _XirrResult(this.f, this.df);
}

enum AssetInterestType { simple, compoundedAnnually, compoundedMonthly }
