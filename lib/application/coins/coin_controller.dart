import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/coin_transaction.dart';

class CoinState {
  final int balance;
  final int loginStreak;
  final bool dailyBonusClaimed;
  final int transactionsToday;
  final int budgetStreak;
  final List<CoinTransaction> history;

  const CoinState({
    this.balance = 0,
    this.loginStreak = 0,
    this.dailyBonusClaimed = false,
    this.transactionsToday = 0,
    this.budgetStreak = 0,
    this.history = const [],
  });

  CoinState copyWith({
    int? balance,
    int? loginStreak,
    bool? dailyBonusClaimed,
    int? transactionsToday,
    int? budgetStreak,
    List<CoinTransaction>? history,
  }) {
    return CoinState(
      balance: balance ?? this.balance,
      loginStreak: loginStreak ?? this.loginStreak,
      dailyBonusClaimed: dailyBonusClaimed ?? this.dailyBonusClaimed,
      transactionsToday: transactionsToday ?? this.transactionsToday,
      budgetStreak: budgetStreak ?? this.budgetStreak,
      history: history ?? this.history,
    );
  }
}

final coinHistoryBoxProvider = Provider<Box>((ref) => throw UnimplementedError());

class CoinController extends StateNotifier<CoinState> {
  final SharedPreferences _prefs;
  final Box _historyBox;

  CoinController(this._prefs, this._historyBox) : super(const CoinState()) {
    _load();
  }

  static int _computeBalance(List<CoinTransaction> history) {
    return history.fold<int>(0, (s, t) => s + t.amount);
  }

  List<CoinTransaction> _readHistory() {
    final raw = _historyBox.get('log');
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List;
    return list.map((e) => CoinTransaction.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _saveHistory(List<CoinTransaction> history) {
    final json = jsonEncode(history.map((t) => t.toJson()).toList());
    _historyBox.put('log', json);
  }

  void _appendTransaction(int amount, CoinReason reason, String label) {
    final history = _readHistory();
    history.add(CoinTransaction(
      timestamp: DateTime.now(),
      amount: amount,
      reason: reason,
      label: label,
    ));
    _saveHistory(history);
  }

  void _load() {
    final history = _readHistory();
    final balance = _computeBalance(history);

    final loginStreak = _prefs.getInt('coin_login_streak') ?? 0;
    final lastLoginDate = _prefs.getString('coin_last_login');
    final transactionsToday = _prefs.getInt('coin_tx_today') ?? 0;

    final today = _today();
    final isNewDay = lastLoginDate != today;

    int newStreak = loginStreak;

    if (isNewDay) {
      if (lastLoginDate == _yesterday()) {
        newStreak = loginStreak + 1;
      } else {
        newStreak = 1;
      }
      _prefs.setString('coin_last_login', today);
      _prefs.setInt('coin_login_streak', newStreak);
      _prefs.setInt('coin_tx_today', 0);

      final streakBonus = (newStreak * 5).clamp(5, 50);
      _appendTransaction(10, CoinReason.dailyLogin, 'Daily login bonus');
      if (streakBonus > 0) {
        _appendTransaction(streakBonus, CoinReason.loginStreak, 'Login streak day $newStreak');
      }
      final newBalance = _computeBalance(_readHistory());

      state = CoinState(
        balance: newBalance,
        loginStreak: newStreak,
        dailyBonusClaimed: false,
        transactionsToday: 0,
        budgetStreak: _prefs.getInt('coin_budget_streak') ?? 0,
        history: _readHistory(),
      );
    } else {
      final claimed = _prefs.getBool('coin_daily_claimed') ?? false;
      state = CoinState(
        balance: balance,
        loginStreak: loginStreak,
        dailyBonusClaimed: claimed,
        transactionsToday: transactionsToday,
        budgetStreak: _prefs.getInt('coin_budget_streak') ?? 0,
        history: history,
      );
    }
  }

  void onTransactionAdded() {
    final txToday = state.transactionsToday;
    if (txToday >= 10) return;

    _appendTransaction(2, CoinReason.transactionAdded, 'Transaction recorded');
    final newBalance = _computeBalance(_readHistory());
    final newTxToday = txToday + 1;

    _prefs.setInt('coin_tx_today', newTxToday);

    state = state.copyWith(
      balance: newBalance,
      transactionsToday: newTxToday,
      history: _readHistory(),
    );
  }

  void onBudgetDayComplete(bool underBudget) {
    if (underBudget) {
      final newStreak = state.budgetStreak + 1;
      _prefs.setInt('coin_budget_streak', newStreak);

      if (newStreak == 30) {
        _appendTransaction(200, CoinReason.budgetStreak30, '30-day budget streak!');
      } else if (newStreak == 7) {
        _appendTransaction(50, CoinReason.budgetStreak7, '7-day budget streak!');
      } else {
        _appendTransaction(5, CoinReason.budgetStreak, 'Budget streak day $newStreak');
      }

      final newBalance = _computeBalance(_readHistory());

      state = state.copyWith(
        balance: newBalance,
        budgetStreak: newStreak,
        history: _readHistory(),
      );
    } else {
      _prefs.setInt('coin_budget_streak', 0);
      state = state.copyWith(budgetStreak: 0);
    }
  }

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  String _yesterday() {
    final n = DateTime.now().subtract(const Duration(days: 1));
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
