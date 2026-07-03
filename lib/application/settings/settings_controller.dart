import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String email;
  final int monthlyBudget;
  final int initialBalance;

  const UserProfile({
    this.name = 'User',
    this.email = '',
    this.monthlyBudget = 0,
    this.initialBalance = 0,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? monthlyBudget,
    int? initialBalance,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

class SettingsState {
  final UserProfile profile;
  final String currencyCode;
  final int firstDayOfWeek;

  const SettingsState({
    this.profile = const UserProfile(),
    this.currencyCode = 'INR',
    this.firstDayOfWeek = DateTime.monday,
  });

  SettingsState copyWith({
    UserProfile? profile,
    String? currencyCode,
    int? firstDayOfWeek,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      currencyCode: currencyCode ?? this.currencyCode,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
    );
  }

  String get currencySymbol {
    switch (currencyCode) {
      case 'INR': return '₹';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default: return '₹';
    }
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsController(this._prefs) : super(const SettingsState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    state = SettingsState(
      profile: UserProfile(
        name: _prefs.getString('profile_name') ?? 'User',
        email: _prefs.getString('profile_email') ?? '',
        monthlyBudget: _prefs.getInt('monthly_budget') ?? 0,
        initialBalance: _prefs.getInt('initial_balance') ?? 0,
      ),
      currencyCode: _prefs.getString('currency_code') ?? 'INR',
      firstDayOfWeek: _prefs.getInt('first_day_of_week') ?? DateTime.monday,
    );
  }

  void _saveToPrefs() {
    _prefs.setString('profile_name', state.profile.name);
    _prefs.setString('profile_email', state.profile.email);
    _prefs.setInt('monthly_budget', state.profile.monthlyBudget);
    _prefs.setInt('initial_balance', state.profile.initialBalance);
    _prefs.setString('currency_code', state.currencyCode);
    _prefs.setInt('first_day_of_week', state.firstDayOfWeek);
  }

  void updateProfile(UserProfile profile) {
    state = state.copyWith(profile: profile);
    _saveToPrefs();
  }

  void updateName(String name) {
    state = state.copyWith(
      profile: state.profile.copyWith(name: name),
    );
    _saveToPrefs();
  }

  void updateEmail(String email) {
    state = state.copyWith(
      profile: state.profile.copyWith(email: email),
    );
    _saveToPrefs();
  }

  void updateMonthlyBudget(int budget) {
    state = state.copyWith(
      profile: state.profile.copyWith(monthlyBudget: budget),
    );
    _saveToPrefs();
  }

  void updateInitialBalance(int balance) {
    state = state.copyWith(
      profile: state.profile.copyWith(initialBalance: balance),
    );
    _saveToPrefs();
  }

  void setCurrency(String code) {
    state = state.copyWith(currencyCode: code);
    _saveToPrefs();
  }

  void setFirstDayOfWeek(int day) {
    state = state.copyWith(firstDayOfWeek: day);
    _saveToPrefs();
  }
}
