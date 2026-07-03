import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../application/settings/settings_controller.dart';
import '../../core/date_range.dart';
import '../../core/money.dart';
import '../../core/theme.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(
            profile: profile,
            onEditName: () =>
                _editName(context, notifier, profile.name),
            onEditEmail: () =>
                _editEmail(context, notifier, profile.email),
            onEditBudget: () => _editBudget(
                context, notifier, profile.monthlyBudget),
            onEditBalance: () => _editInitialBalance(
                context, notifier, profile.initialBalance),
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'PREFERENCES',
            children: [
              _ThemeTile(themeMode: themeMode, ref: ref),
              _DefaultRangeTile(defaultRange: defaultRange, ref: ref),
              _CurrencyTile(
                currency: settings.currencyCode,
                onChanged: (v) => notifier.setCurrency(v),
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
            title: 'SAVINGS',
            children: [
              _SavingsGoalTile(
                profile: profile,
                ref: ref,
                onSetGoal: () => _editSavingsGoal(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'DATA',
            children: [
              _ExportTile(ref: ref),
              _ResetTile(ref: ref),
            ],
          ),
          const SizedBox(height: 24),
          _Section(
            title: 'ABOUT',
            children: [
              _Tile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '0.1.0',
              ),
              _Tile(
                icon: Icons.code,
                title: 'Built with Flutter',
                subtitle: 'ClearSpend • Premium Finance Tracker',
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
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

  void _editInitialBalance(
      BuildContext context, SettingsController notifier, int current) {
    final strVal =
        current > 0 ? (current / 100).toStringAsFixed(0) : '';
    final controller = TextEditingController(text: strVal);
    showDialog(
      context: context,
      builder: (ctx) => _StyledDialog(
        title: 'Initial Balance',
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: _inputDec('Enter initial balance', prefix: '₹ '),
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifier.updateInitialBalance(0);
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () {
              final v = Money.parseToMinor(controller.text.trim());
              if (v != null) notifier.updateInitialBalance(v);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editSavingsGoal(BuildContext context, WidgetRef ref) {
    final current = ref.read(savingsGoalProvider);
    final strVal = current > 0 ? (current / 100).toStringAsFixed(0) : '';
    final controller = TextEditingController(text: strVal);
    showDialog(
      context: context,
      builder: (ctx) => _StyledDialog(
        title: 'Monthly Savings Goal',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How much do you want to save each month?',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: _inputDec('Enter savings goal', prefix: '₹ '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(savingsGoalProvider.notifier).state = 0;
              ref.read(sharedPreferencesProvider).remove('savings_goal');
              Navigator.pop(ctx);
            },
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () {
              final v = Money.parseToMinor(controller.text.trim());
              if (v != null) {
                ref.read(savingsGoalProvider.notifier).state = v;
                ref.read(sharedPreferencesProvider).setInt('savings_goal', v);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
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
  final VoidCallback onEditName;
  final VoidCallback onEditEmail;
  final VoidCallback onEditBudget;
  final VoidCallback onEditBalance;
  const _ProfileCard({
    required this.profile,
    required this.onEditName,
    required this.onEditEmail,
    required this.onEditBudget,
    required this.onEditBalance,
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
          CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primaryGlass,
            child: Text(profile.initials,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary)),
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
                Icon(Icons.edit,
                    size: 16, color: AppTheme.textSecondary),
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
          const SizedBox(height: 10),
          _buildAction(
            icon: Icons.monetization_on_outlined,
            text: profile.initialBalance > 0
                ? 'Balance: ${Money.format(profile.initialBalance)}'
                : 'Set initial balance',
            onTap: onEditBalance,
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
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentGlass,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accent, size: 20),
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
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          onTap: onTap,
        ),
        if (onTap != null)
          const Divider(height: 1, indent: 72, endIndent: 16),
      ],
    );
  }
}

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
            .map((t) => PopupMenuItem(
                value: t, child: Text(_label(t))))
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
  final ValueChanged<String> onChanged;
  const _CurrencyTile({required this.currency, required this.onChanged});

  static const _currencies = [
    ('INR', '₹', 'Indian Rupee'),
    ('USD', '\$', 'US Dollar'),
    ('EUR', '€', 'Euro'),
    ('GBP', '£', 'British Pound'),
  ];

  String _currencyLabel(String code) {
    for (final c in _currencies) {
      if (c.$1 == code) return '${c.$2} ${c.$3}';
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.warningGlass,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.monetization_on_outlined,
            color: AppTheme.warning, size: 20),
      ),
      title: const Text('Currency',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary)),
      subtitle: Text(_currencyLabel(currency),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      trailing: PopupMenuButton<String>(
        onSelected: onChanged,
        itemBuilder: (_) => _currencies
            .map((c) => PopupMenuItem(
                value: c.$1, child: Text('${c.$2}  ${c.$3}')))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.warningGlass,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(currency,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warning)),
        ),
      ),
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
            .map((d) => PopupMenuItem(
                value: d.$1, child: Text(d.$2)))
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

class _SavingsGoalTile extends StatelessWidget {
  final UserProfile profile;
  final WidgetRef ref;
  final VoidCallback onSetGoal;
  const _SavingsGoalTile({
    required this.profile,
    required this.ref,
    required this.onSetGoal,
  });

  @override
  Widget build(BuildContext context) {
    final goal = ref.watch(savingsGoalProvider);
    final historyState = ref.watch(historyControllerProvider);
    final saved = historyState.totalIncome - historyState.totalExpense;
    final goalDisplay = goal > 0 ? Money.format(goal) : 'Not set';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.savings, size: 18, color: AppTheme.income),
              const SizedBox(width: 8),
              const Text('Monthly Savings Goal',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Flexible(
                child: Text(goalDisplay,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary)),
              ),
            ],
          ),
          if (goal > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (saved / goal).clamp(0, 1),
                minHeight: 10,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  saved >= goal ? AppTheme.income : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Saved: ${Money.format(saved)}',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                Text(
                  saved >= goal
                      ? 'Goal reached!'
                      : '${((saved / goal) * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: saved >= goal ? AppTheme.income : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSetGoal,
              child: Text(goal > 0 ? 'Update Goal' : 'Set Goal'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final WidgetRef ref;
  const _ExportTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      icon: Icons.file_download_outlined,
      title: 'Export Data',
      subtitle: 'Download your expenses as CSV',
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export feature coming soon')),
        );
      },
    );
  }
}

class _ResetTile extends StatelessWidget {
  final WidgetRef ref;
  const _ResetTile({required this.ref});

  @override
  Widget build(BuildContext context) {
    return _Tile(
      icon: Icons.delete_forever_outlined,
      title: 'Reset All Data',
      subtitle: 'Delete all expenses and start fresh',
      onTap: () => _confirmReset(context),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset All Data?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'This will permanently delete all your expenses and EMI records. This action cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.expense,
            ),
            onPressed: () async {
              await ref.read(expenseRepositoryProvider).clearAll();
              await ref.read(emiRepositoryProvider).clearAll();
              ref.invalidate(historyControllerProvider);
              ref.invalidate(analysisControllerProvider);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data reset complete')),
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
