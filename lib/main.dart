// ENTRY POINT
// Order is a dependency chain, not style:
//   1. binding  -> enables platform channels
//   2. openIsar -> needs channels (path_provider)
//   3. override -> needs the opened instance
//   4. runApp   -> last

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'application/providers.dart';
import 'data/sources/isar_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await openIsar();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MoneyMateApp(),
    ),
  );
}
