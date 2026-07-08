import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/investment_calculator.dart';
import '../../domain/models/investment.dart';
import '../../domain/models/sip_installment.dart';
import '../../domain/repositories/investment_repository.dart';
import '../../domain/repositories/sip_installment_repository.dart';

class InvestmentState {
  final List<Investment> allInvestments;
  final Map<int, List<SipInstallment>> sipInstallments;
  final String? error;

  const InvestmentState({
    this.allInvestments = const [],
    this.sipInstallments = const {},
    this.error,
  });

  List<SipInstallment> installmentsFor(int investmentId) =>
      sipInstallments[investmentId] ?? [];

  int sipTotalInvested(int investmentId) {
    return installmentsFor(investmentId)
        .fold<int>(0, (s, i) => s + i.amount);
  }

  int sipInstallmentsPaid(int investmentId) =>
      installmentsFor(investmentId).length;

  Map<AssetType, List<Investment>> get groupedByType {
    final map = <AssetType, List<Investment>>{};
    for (final inv in allInvestments) {
      map.putIfAbsent(inv.assetType, () => []).add(inv);
    }
    return map;
  }

  int get totalInvested =>
      allInvestments.fold<int>(0, (s, i) => s + i.totalInvested);
  int get totalCurrentValue =>
      allInvestments.fold<int>(0, (s, i) => s + i.currentValue);
  int get totalGain => totalCurrentValue - totalInvested;
  double get gainPercent =>
      totalInvested > 0 ? (totalGain / totalInvested) * 100 : 0;

  double get xirr {
    if (allInvestments.isEmpty) return 0;
    final now = DateTime.now();
    final flows = <double>[];
    final dates = <DateTime>[];
    for (final inv in allInvestments) {
      flows.add(-inv.totalInvested.toDouble());
      dates.add(inv.investedDate);
    }
    flows.add(totalCurrentValue.toDouble());
    dates.add(now);
    return InvestmentCalculator.xirr(flows, dates) * 100;
  }

  Map<String, double> get assetAllocation {
    final total = totalInvested > 0 ? totalInvested : 1;
    final map = <String, double>{};
    for (final inv in allInvestments) {
      final cat = _allocationCategory(inv.assetType);
      map.update(cat, (v) => v + inv.currentValue, ifAbsent: () => inv.currentValue.toDouble());
    }
    final result = <String, double>{};
    for (final e in map.entries) {
      result[e.key] = (e.value / totalCurrentValue) * 100;
    }
    return result;
  }

  static String _allocationCategory(AssetType type) {
    switch (type) {
      case AssetType.stocks:
      case AssetType.mutualFund:
      case AssetType.sip:
        return 'Equity';
      case AssetType.fd:
      case AssetType.ppf:
      case AssetType.bonds:
      case AssetType.nps:
        return 'Debt';
      case AssetType.gold:
        return 'Gold';
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.other:
        return 'Other';
    }
  }

  List<Investment> get nearingMaturity {
    return allInvestments.where((inv) {
      if (!inv.assetType.hasMaturity || inv.maturityDate == null) return false;
      final days = InvestmentCalculator.daysBetween(DateTime.now(), inv.maturityDate!);
      return days >= 0 && days <= 30;
    }).toList();
  }
}

class InvestmentController extends StateNotifier<InvestmentState> {
  final InvestmentRepository _repository;
  final SipInstallmentRepository _sipRepo;
  StreamSubscription<List<Investment>>? _subscription;
  final Map<int, StreamSubscription<List<SipInstallment>>> _sipSubs = {};

  InvestmentController(this._repository, this._sipRepo)
      : super(const InvestmentState()) {
    _subscription = _repository.watchAll().listen(_onInvestmentsChanged);
  }

  void _onInvestmentsChanged(List<Investment> investments) {
    state = state.copyWith(allInvestments: investments, clearError: true);
    _subscribeSipInstallments(investments);
  }

  void _subscribeSipInstallments(List<Investment> investments) {
    _sipSubs.values.forEach((s) => s.cancel());
    _sipSubs.clear();
    for (final inv in investments) {
      if (!inv.isSip || inv.id == null) continue;
      final sub = _sipRepo.watchForInvestment(inv.id!).listen((installments) {
        final map = Map<int, List<SipInstallment>>.from(state.sipInstallments);
        map[inv.id!] = installments;
        state = state.copyWith(sipInstallments: map);
      });
      _sipSubs[inv.id!] = sub;
    }
  }

  Future<void> addInvestment(Investment inv) async {
    if (inv.name.trim().isEmpty) {
      state = state.copyWith(error: 'Enter an investment name');
      return;
    }
    await _repository.save(inv);
  }

  Future<void> updatePrice(int id, int newPrice) async {
    final inv = state.allInvestments.firstWhere((i) => i.id == id);
    await _repository.save(inv.copyWith(
      currentPricePerUnit: newPrice,
      lastUpdatedAt: DateTime.now(),
    ));
  }

  Future<void> bulkUpdatePrices(Map<int, int> priceMap) async {
    for (final entry in priceMap.entries) {
      final inv = state.allInvestments.firstWhere((i) => i.id == entry.key);
      await _repository.save(inv.copyWith(
        currentPricePerUnit: entry.value,
        lastUpdatedAt: DateTime.now(),
      ));
    }
  }

  Future<void> addSipInstallment(int investmentId, int amount, {double? nav, double? units}) async {
    await _sipRepo.save(SipInstallment(
      investmentId: investmentId,
      amount: amount,
      date: DateTime.now(),
      nav: nav,
      unitsAllotted: units,
    ));
  }

  Future<void> deleteInvestment(int id) async {
    await _repository.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sipSubs.values.forEach((s) => s.cancel());
    super.dispose();
  }
}

extension InvestmentStateX on InvestmentState {
  InvestmentState copyWith({
    List<Investment>? allInvestments,
    Map<int, List<SipInstallment>>? sipInstallments,
    String? error,
    bool clearError = false,
  }) {
    return InvestmentState(
      allInvestments: allInvestments ?? this.allInvestments,
      sipInstallments: sipInstallments ?? this.sipInstallments,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
