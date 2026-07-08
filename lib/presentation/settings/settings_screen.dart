import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';

import '../../application/providers.dart';
import '../../application/settings/app_settings.dart';
import '../../application/settings/backup_service.dart';
import '../../application/settings/settings_controller.dart';
import '../../core/date_range.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import 'about_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);
    final profile = settings.profile;
    final themeMode = ref.watch(themeModeProvider);
    final defaultRange = ref.watch(defaultRangeTypeProvider);
    final historyState = ref.watch(historyControllerProvider);
    final currentSpend = historyState.total;
    final biometricLock = ref.watch(biometricLockProvider);
    final notifyRecurring = ref.watch(notifyRecurringProvider);
    final notifyEmi = ref.watch(notifyEmiProvider);
    final notifyLedger = ref.watch(notifyLedgerProvider);
    final notifyBudget = ref.watch(notifyBudgetProvider);
    final currencyCode = ref.watch(currencyCodeProvider);
    final formatMoney = ref.watch(formatMoneyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(
            profile: profile,
            onEditImage: () => _pickImage(context, ref),
            onEditName: () => _editName(context, notifier, profile.name),
            onEditEmail: () => _editEmail(context, notifier, profile.email),
            onEditBudget: () =>
                _editBudget(context, notifier, profile.monthlyBudget),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'PREFERENCES',
            children: [
              _ThemeTile(themeMode: themeMode, ref: ref),
              _DefaultRangeTile(defaultRange: defaultRange, ref: ref),
              _CurrencyTile(
                currency: currencyCode,
                formatMoney: formatMoney,
                onChange: (code) {
                  final box = ref.read(settingsBoxProvider);
                  box.put('currencyCode', code);
                },
              ),
              _WeekStartTile(
                firstDay: settings.firstDayOfWeek,
                onChanged: (v) => notifier.setFirstDayOfWeek(v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (profile.monthlyBudget > 0) ...[
            _Section(
              title: 'BUDGET OVERVIEW',
              children: [
                _BudgetTile(
                    budget: profile.monthlyBudget, spent: currentSpend),
              ],
            ),
            const SizedBox(height: 24),
          ],
          _Section(
            title: 'SECURITY',
            children: [
              _BiometricLockTile(
                enabled: biometricLock,
                onChanged: (v) => _toggleBiometricLock(context, ref, v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'NOTIFICATIONS',
            children: [
              _NotificationTile(
                icon: Icons.repeat,
                title: 'Recurring Transactions',
                value: notifyRecurring,
                onChanged: (v) {
                  ref.read(notifyRecurringProvider.notifier).state = v;
                  ref.read(settingsBoxProvider).put('notifyRecurring', v);
                },
              ),
              _NotificationTile(
                icon: Icons.credit_card,
                title: 'EMI Due Reminders',
                value: notifyEmi,
                onChanged: (v) {
                  ref.read(notifyEmiProvider.notifier).state = v;
                  ref.read(settingsBoxProvider).put('notifyEmi', v);
                },
              ),
              _NotificationTile(
                icon: Icons.book,
                title: 'Ledger Due Dates',
                value: notifyLedger,
                onChanged: (v) {
                  ref.read(notifyLedgerProvider.notifier).state = v;
                  ref.read(settingsBoxProvider).put('notifyLedger', v);
                },
              ),
              _NotificationTile(
                icon: Icons.pie_chart,
                title: 'Budget Overage Alerts',
                value: notifyBudget,
                onChanged: (v) {
                  ref.read(notifyBudgetProvider.notifier).state = v;
                  ref.read(settingsBoxProvider).put('notifyBudget', v);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'DATA',
            children: [
              const _BackupTile(),
              const _RestoreTile(),
              _ResetTile(ref: ref),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'ABOUT',
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlass,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline,
                      color: AppTheme.accent, size: 20),
                ),
                title: const Text('About ClearSpend',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                subtitle: const Text('Version 1.0.0',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                trailing: const Icon(Icons.chevron_right,
                    size: 18, color: AppTheme.textSecondary),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _toggleBiometricLock(
      BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      final localAuth = LocalAuthentication();
      final canCheck = await localAuth.canCheckBiometrics;
      if (!canCheck) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Biometrics not available on this device')),
          );
        }
        return;
      }
      final authenticated = await localAuth.authenticate(
        localizedReason: 'Enable app lock with biometrics',
      );
      if (!authenticated) return;
    }
    ref.read(biometricLockProvider.notifier).state = enable;
    ref.read(settingsBoxProvider).put('biometricLock', enable);
  }

  void _editName(
      BuildContext context, SettingsController notifier, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => _StyledDialog(
        title: 'Your Name',
        child: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: _inputDec('Enter your name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = controller.text.trim();
              if (v.isNotEmpty) notifier.updateName(v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editEmail(
      BuildContext context, SettingsController notifier, String current) {
    final controller = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (ctx) => _StyledDialog(
        title: 'Email',
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: _inputDec('Enter your email'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              notifier.updateEmail(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBudget(
      BuildContext context, SettingsController notifier, int current) {
    final strVal =
        current > 0 ? (current / 100).toStringAsFixed(0) : '';
    final controller = TextEditingController(text: strVal);
    showDialog(
      context: context,
      builder: (ctx) => _StyledDialog(
        title: 'Monthly Budget',
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: _inputDec('Enter monthly budget', prefix: '₹ '),
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.updateMonthlyBudget(0);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () {
              final v = Money.parseToMinor(controller.text.trim());
              if (v != null) notifier.updateMonthlyBudget(v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Profile Picture',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _sourceOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () => Navigator.pop(ctx, ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sourceOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (ref
                    .read(settingsControllerProvider)
                    .profile
                    .imagePath !=
                null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(settingsControllerProvider.notifier)
                        .updateImage(null);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remove photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.expense,
                    side: const BorderSide(color: AppTheme.expense),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked != null) {
      ref
          .read(settingsControllerProvider.notifier)
          .updateImage(picked.path);
    }
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.cardGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String hint, {String prefix = ''}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: AppTheme.bg.withAlpha(100),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppTheme.border),
      ),
    );
  }
}

// ── Widgets ──

class _StyledDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  const _StyledDialog({
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,
          style: const TextStyle(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
      content: child,
      actions: actions,
      backgroundColor: AppTheme.cardSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditImage;
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onEditBudget;
  const _ProfileCard({
    required this.profile,
    required this.onEditImage,
    required this.onEditName,
    required this.onEditEmail,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2A4A), Color(0xFF0F1D3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.primary.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(20),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEditImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppTheme.primaryGlass,
                  backgroundImage: profile.imagePath != null
                      ? FileImage(File(profile.imagePath!))
                      : null,
                  child: profile.imagePath == null
                      ? Text(profile.initials,
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onEditName,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onEditEmail,
            child: Text(
                profile.email.isEmpty ? 'Tap to add email' : profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
          const SizedBox(height: 16),
          _buildAction(
            icon: Icons.account_balance_wallet_outlined,
            text: profile.monthlyBudget > 0
                ? 'Budget: ${Money.format(profile.monthlyBudget)}/mo'
                : 'Set monthly budget',
            onTap: onEditBudget,
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardGlass,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(180),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _Tile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.accent;
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary)),
          subtitle: Text(subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          trailing: onTap != null
              ? const Icon(Icons.chevron_right,
                    size: 18, color: AppTheme.textSecondary)
              : null,
          onTap: onTap,
        ),
        if (onTap != null) const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }
}

// ── Preference Tiles ──

class _ThemeTile extends StatelessWidget {
  final ThemeMode themeMode;
  final WidgetRef ref;
  const _ThemeTile({required this.themeMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  themeMode == ThemeMode.light
                      ? Icons.light_mode
                      : themeMode == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.brightness_auto,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: const Text('Theme',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(
                    value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (v) =>
                  ref.read(themeModeProvider.notifier).state = v.first,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultRangeTile extends StatelessWidget {
  final DateRangeType defaultRange;
  final WidgetRef ref;
  const _DefaultRangeTile({required this.defaultRange, required this.ref});

  String _label(DateRangeType t) {
    switch (t) {
      case DateRangeType.today: return 'Today';
      case DateRangeType.week: return 'Week';
      case DateRangeType.month: return 'Month';
      case DateRangeType.year: return 'Year';
      case DateRangeType.custom: return 'Custom';
    }
  }

  IconData _icon(DateRangeType t) {
    switch (t) {
      case DateRangeType.today: return Icons.today;
      case DateRangeType.week: return Icons.date_range;
      case DateRangeType.month: return Icons.calendar_month;
      case DateRangeType.year: return Icons.event_note;
      case DateRangeType.custom: return Icons.edit_calendar;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.incomeGlass,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_icon(defaultRange),
            color: AppTheme.income, size: 20),
      ),
      title: const Text('Default View',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary)),
      subtitle: Text('Show ${_label(defaultRange)} by default',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: PopupMenuButton<DateRangeType>(
        onSelected: (v) =>
            ref.read(defaultRangeTypeProvider.notifier).state = v,
        itemBuilder: (_) => DateRangeType.values
            .map((t) =>
                PopupMenuItem(value: t, child: Text(_label(t))))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.incomeGlass,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_label(defaultRange),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.income)),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  final String currency;
  final String Function(int) formatMoney;
  final ValueChanged<String> onChange;
  const _CurrencyTile({
    required this.currency,
    required this.formatMoney,
    required this.onChange,
  });

  static const _currencies = [
    ('INR', '₹', 'Indian Rupee'),
    ('USD', r'$', 'US Dollar'),
    ('EUR', '€', 'Euro'),
    ('GBP', '£', 'British Pound'),
    ('JPY', '¥', 'Japanese Yen'),
    ('CNY', '¥', 'Chinese Yuan'),
    ('AED', 'د.إ', 'UAE Dirham'),
    ('SAR', '﷼', 'Saudi Riyal'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _currencies.firstWhere(
      (c) => c.$1 == currency,
      orElse: () => ('INR', '₹', 'Indian Rupee'),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monetization_on_outlined,
                    color: AppTheme.warning, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: const Text('Currency',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CurrencyPicker(
            currencies: _currencies,
            selectedCode: currency,
            onChanged: onChange,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text('${current.$2}  ',
                    style: const TextStyle(
                        fontSize: 16, color: AppTheme.textPrimary)),
                Expanded(
                  child: Text(
                    '${formatMoney(123450)} preview',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  final List<(String, String, String)> currencies;
  final String selectedCode;
  final ValueChanged<String> onChanged;

  const _CurrencyPicker({
    required this.currencies,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: currencies.map((c) {
        final isSelected = c.$1 == selectedCode;
        return GestureDetector(
          onTap: () => onChanged(c.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.warning.withAlpha(30)
                  : AppTheme.cardSurface.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.warning.withAlpha(120)
                    : AppTheme.border,
              ),
            ),
            child: Column(
              children: [
                Text(c.$2,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? AppTheme.warning
                            : AppTheme.textPrimary)),
                Text(c.$1,
                    style: TextStyle(
                        fontSize: 10,
                        color: isSelected
                            ? AppTheme.warning
                            : AppTheme.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekStartTile extends StatelessWidget {
  final int firstDay;
  final ValueChanged<int> onChanged;
  const _WeekStartTile({required this.firstDay, required this.onChanged});

  static const _days = [
    (DateTime.monday, 'Monday'),
    (DateTime.sunday, 'Sunday'),
    (DateTime.saturday, 'Saturday'),
  ];

  @override
  Widget build(BuildContext context) {
    final label = _days
        .firstWhere((d) => d.$1 == firstDay,
            orElse: () => (DateTime.monday, 'Monday'))
        .$2;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGlass,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.calendar_view_week,
            color: AppTheme.primary, size: 20),
      ),
      title: const Text('Week Starts On',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary)),
      subtitle: Text(label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: PopupMenuButton<int>(
        onSelected: onChanged,
        itemBuilder: (_) => _days
            .map((d) => PopupMenuItem(value: d.$1, child: Text(d.$2)))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGlass,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary)),
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  final int budget;
  final int spent;
  const _BudgetTile({required this.budget, required this.spent});

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = (budget - spent).clamp(0, budget);
    final overBudget = spent > budget;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                overBudget
                    ? Icons.warning_amber_rounded
                    : Icons.account_balance_wallet_rounded,
                size: 18,
                color: overBudget ? AppTheme.expense : AppTheme.income,
              ),
              const SizedBox(width: 8),
              const Text('Monthly Budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Flexible(
                child: Text('${Money.format(spent)} / ${Money.format(budget)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                overBudget
                    ? AppTheme.expense
                    : ratio > 0.8
                        ? AppTheme.warning
                        : AppTheme.income,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${(ratio * 100).round()}% used',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const Spacer(),
              Text(
                overBudget
                    ? 'Over budget!'
                    : '${Money.format(remaining)} remaining',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: overBudget
                        ? AppTheme.expense
                        : AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Security Tile ──

class _BiometricLockTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _BiometricLockTile({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fingerprint,
                color: AppTheme.accent, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Lock',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(
                  enabled
                      ? 'Biometric lock enabled'
                      : 'Require biometric to open',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ── Notification Tile ──

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
          ),
          SizedBox(
            height: 28,
            child: Switch.adaptive(
              value: value,
              activeColor: AppTheme.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Backup & Restore ──

class _BackupTile extends ConsumerWidget {
  const _BackupTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Tile(
      icon: Icons.backup,
      iconColor: AppTheme.income,
      title: 'Backup Data',
      subtitle: 'Export all data to a JSON file',
      onTap: () => _doBackup(context, ref),
    );
  }

  Future<void> _doBackup(BuildContext context, WidgetRef ref) async {
    try {
      final isar = ref.read(isarProvider);
      final path = await BackupService.exportToJson(isar);
      if (path != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved to $path')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }
}

class _RestoreTile extends ConsumerWidget {
  const _RestoreTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Tile(
      icon: Icons.restore,
      iconColor: AppTheme.warning,
      title: 'Restore Data',
      subtitle: 'Import from a backup file',
      onTap: () => _confirmRestore(context, ref),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Restore Backup?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will overwrite ALL your current data with the backup. '
          'This action cannot be undone. Make sure you have a current backup '
          'if needed.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.warning),
            onPressed: () async {
              Navigator.pop(ctx);
              await _doRestore(context, ref);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _doRestore(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final isar = ref.read(isarProvider);
      final count =
          await BackupService.importFromJson(isar, result.files.single.path!);

      ref.invalidate(historyControllerProvider);
      ref.invalidate(analysisControllerProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restored $count records successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }
}

// ── Reset ──

class _ResetTile extends ConsumerWidget {
  final WidgetRef ref;
  const _ResetTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Tile(
      icon: Icons.delete_forever_outlined,
      iconColor: AppTheme.expense,
      title: 'Clear All Data',
      subtitle: 'Delete all records and start fresh',
      onTap: () => _confirmReset(context),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently delete all your expenses, EMIs, '
          'khata entries, trades, budgets, goals, and investments. '
          'This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _confirmFinalReset(context);
            },
            child: const Text('Delete Everything',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }

  void _confirmFinalReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Are you absolutely sure?',
            style: TextStyle(color: AppTheme.expense)),
        content: const Text(
          'This is your final warning. All your financial data will be '
          'permanently erased. Consider exporting a backup first.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.expense),
            onPressed: () async {
              Navigator.pop(ctx);
              await BackupService.clearAllData(ref.read(isarProvider));
              ref.invalidate(historyControllerProvider);
              ref.invalidate(analysisControllerProvider);
              ref.invalidate(tradeControllerProvider);
              ref.invalidate(khataControllerProvider);
              ref.invalidate(budgetControllerProvider);
              ref.invalidate(investmentControllerProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              }
            },
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
