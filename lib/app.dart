import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/providers.dart';
import 'core/theme.dart';
import 'presentation/settings/biometric_gate.dart';
import 'presentation/shell/main_shell.dart';

class ClearSpendApp extends ConsumerWidget {
  const ClearSpendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    ref.listen(themeModeProvider, (_, next) {
      ref.read(sharedPreferencesProvider).setString('theme_mode', next.name);
    });

    ref.listen(defaultRangeTypeProvider, (_, next) {
      ref
          .read(sharedPreferencesProvider)
          .setInt('default_range_type', next.index);
    });

    return MaterialApp(
      title: 'ClearSpend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: const BiometricGate(child: MainShell()),
    );
  }
}
