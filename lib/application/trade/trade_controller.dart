import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/trade.dart';
import '../../domain/repositories/trade_repository.dart';

class TradeState {
  final List<Trade> allTrades;
  final TradeStatus? filterStatus;
  final TradeType? filterType;
  final String? error;

  const TradeState({
    this.allTrades = const [],
    this.filterStatus,
    this.filterType,
    this.error,
  });

  List<Trade> get filteredTrades {
    var result = allTrades;
    if (filterStatus != null) {
      result = result.where((t) => t.status == filterStatus).toList();
    }
    if (filterType != null) {
      result = result.where((t) => t.tradeType == filterType).toList();
    }
    return result;
  }

  List<Trade> get closedTrades =>
      allTrades.where((t) => t.status == TradeStatus.closed).toList();

  int get totalPnl =>
      closedTrades.fold<int>(0, (sum, t) => sum + t.netPnl);

  int get winCount => closedTrades.where((t) => t.isProfitable).length;
  int get lossCount => closedTrades.where((t) => !t.isProfitable).length;

  double get winRate =>
      closedTrades.isEmpty ? 0 : (winCount / closedTrades.length) * 100;

  int get avgProfit {
    final wins = closedTrades.where((t) => t.isProfitable).toList();
    if (wins.isEmpty) return 0;
    return wins.fold<int>(0, (s, t) => s + t.netPnl) ~/ wins.length;
  }

  int get avgLoss {
    final losses = closedTrades.where((t) => !t.isProfitable).toList();
    if (losses.isEmpty) return 0;
    return losses.fold<int>(0, (s, t) => s + t.netPnl) ~/ losses.length;
  }

  int get largestWin {
    if (closedTrades.isEmpty) return 0;
    return closedTrades
        .where((t) => t.isProfitable)
        .fold<int>(0, (max, t) => t.netPnl > max ? t.netPnl : max);
  }

  int get largestLoss {
    if (closedTrades.isEmpty) return 0;
    return closedTrades
        .where((t) => !t.isProfitable)
        .fold<int>(0, (min, t) => t.netPnl < min ? t.netPnl : min);
  }

  TradeState copyWith({
    List<Trade>? allTrades,
    TradeStatus? filterStatus,
    TradeType? filterType,
    String? error,
    bool clearError = false,
    bool clearFilterStatus = false,
    bool clearFilterType = false,
  }) {
    return TradeState(
      allTrades: allTrades ?? this.allTrades,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TradeController extends StateNotifier<TradeState> {
  final TradeRepository _repository;
  StreamSubscription<List<Trade>>? _subscription;

  TradeController(this._repository) : super(const TradeState()) {
    _subscription = _repository.watchAll().listen(_onTradesChanged);
  }

  void _onTradesChanged(List<Trade> trades) {
    state = state.copyWith(allTrades: trades, clearError: true);
  }

  void setFilterStatus(TradeStatus? status) {
    state = state.copyWith(filterStatus: status);
  }

  void setFilterType(TradeType? type) {
    state = state.copyWith(filterType: type);
  }

  Future<void> addTrade(Trade trade) async {
    if (trade.instrumentName.trim().isEmpty) {
      state = state.copyWith(error: 'Enter instrument name');
      return;
    }
    if (trade.quantity <= 0) {
      state = state.copyWith(error: 'Enter valid quantity');
      return;
    }
    await _repository.save(trade);
  }

  Future<void> closeTrade(int id, int exitPrice, DateTime exitDate) async {
    final trade = state.allTrades.firstWhere((t) => t.id == id);
    final updated = trade.copyWith(
      status: TradeStatus.closed,
      exitPrice: exitPrice,
      exitDate: exitDate,
    );
    await _repository.save(updated);
  }

  Future<void> deleteTrade(int id) async {
    await _repository.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
