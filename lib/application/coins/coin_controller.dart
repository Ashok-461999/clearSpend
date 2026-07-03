import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinState {
  final int balance;
  final int loginStreak;
  final bool dailyBonusClaimed;
  final int transactionsToday;
  final int budgetStreak;

  const CoinState({
    this.balance = 0,
    this.loginStreak = 0,
    this.dailyBonusClaimed = false,
    this.transactionsToday = 0,
    this.budgetStreak = 0,
  });

  CoinState copyWith({
    int? balance,
    int? loginStreak,
    bool? dailyBonusClaimed,
    int? transactionsToday,
    int? budgetStreak,
  }) {
    return CoinState(
      balance: balance ?? this.balance,
      loginStreak: loginStreak ?? this.loginStreak,
      dailyBonusClaimed: dailyBonusClaimed ?? this.dailyBonusClaimed,
      transactionsToday: transactionsToday ?? this.transactionsToday,
      budgetStreak: budgetStreak ?? this.budgetStreak,
    );
  }
}

class CoinController extends StateNotifier<CoinState> {
  final SharedPreferences _prefs;

  CoinController(this._prefs) : super(const CoinState()) {
    _load();
  }

  void _load() {
    final balance = _prefs.getInt('coin_balance') ?? 0;
    final loginStreak = _prefs.getInt('coin_login_streak') ?? 0;
    final lastLoginDate = _prefs.getString('coin_last_login');
    final transactionsToday = _prefs.getInt('coin_tx_today') ?? 0;

    final today = _today();
    final isNewDay = lastLoginDate != today;

    int newStreak = loginStreak;
    bool claimed = false;

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
      final newBalance = balance + 10 + streakBonus;
      _prefs.setInt('coin_balance', newBalance);

      state = CoinState(
        balance: newBalance,
        loginStreak: newStreak,
        dailyBonusClaimed: false,
        transactionsToday: 0,
        budgetStreak: _prefs.getInt('coin_budget_streak') ?? 0,
      );
    } else {
      claimed = _prefs.getBool('coin_daily_claimed') ?? false;
      state = CoinState(
        balance: balance,
        loginStreak: loginStreak,
        dailyBonusClaimed: claimed,
        transactionsToday: transactionsToday,
        budgetStreak: _prefs.getInt('coin_budget_streak') ?? 0,
      );
    }
  }

  void onTransactionAdded() {
    final txToday = state.transactionsToday;
    if (txToday >= 10) return;

    final earned = 2;
    final newBalance = state.balance + earned;
    final newTxToday = txToday + 1;

    _prefs.setInt('coin_balance', newBalance);
    _prefs.setInt('coin_tx_today', newTxToday);

    state = state.copyWith(
      balance: newBalance,
      transactionsToday: newTxToday,
    );
  }

  void onBudgetDayComplete(bool underBudget) {
    if (underBudget) {
      final newStreak = state.budgetStreak + 1;
      _prefs.setInt('coin_budget_streak', newStreak);

      int bonus = 5;
      if (newStreak == 7) bonus = 50;
      if (newStreak == 30) bonus = 200;

      final newBalance = state.balance + bonus;
      _prefs.setInt('coin_balance', newBalance);

      state = state.copyWith(
        balance: newBalance,
        budgetStreak: newStreak,
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
