import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String name;
  final String email;
  final int monthlyBudget;
  final String? imagePath;

  const UserProfile({
    this.name = 'User',
    this.email = '',
    this.monthlyBudget = 0,
    this.imagePath,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? monthlyBudget,
    String? imagePath,
    bool clearImage = false,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
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
        imagePath: _prefs.getString('profile_image'),
      ),
      currencyCode: _prefs.getString('currency_code') ?? 'INR',
      firstDayOfWeek: _prefs.getInt('first_day_of_week') ?? DateTime.monday,
    );
  }

  void _saveToPrefs() {
    _prefs.setString('profile_name', state.profile.name);
    _prefs.setString('profile_email', state.profile.email);
    _prefs.setInt('monthly_budget', state.profile.monthlyBudget);
    _prefs.setString('currency_code', state.currencyCode);
    _prefs.setInt('first_day_of_week', state.firstDayOfWeek);
    if (state.profile.imagePath != null) {
      _prefs.setString('profile_image', state.profile.imagePath!);
    } else {
      _prefs.remove('profile_image');
    }
  }

  void updateImage(String? path) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        imagePath: path,
        clearImage: path == null,
      ),
    );
    _saveToPrefs();
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

  void setCurrency(String code) {
    state = state.copyWith(currencyCode: code);
    _saveToPrefs();
  }

  void setFirstDayOfWeek(int day) {
    state = state.copyWith(firstDayOfWeek: day);
    _saveToPrefs();
  }
}
