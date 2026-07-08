import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/goal.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});
  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets & Goals'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Budgets'),
            Tab(text: 'Goals'),
            Tab(text: 'Chart'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          _BudgetsTab(),
          _GoalsTab(),
          _ChartTab(),
        ],
      ),
    );
  }
}

// ── Budgets Tab ──

class _BudgetsTab extends ConsumerWidget {
  const _BudgetsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetControllerProvider);
    final cats = Category.values.where((c) => !c.isIncome).toList();
    final overBudgetCats = cats.where((c) {
      final p = state.progressForCategory(c);
      return p >= 0.9 && state.limitForCategory(c) != null;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (overBudgetCats.isNotEmpty) ...[
          _OverBudgetBanner(categories: overBudgetCats),
          const SizedBox(height: 12),
        ],
        ...cats.map((cat) => _BudgetRow(
              category: cat,
              spent: state.spentForCategory(cat),
              limit: state.limitForCategory(cat),
              onSetLimit: (limit) => ref
                  .read(budgetControllerProvider.notifier)
                  .setBudget(cat, limit),
            )),
      ],
    );
  }
}

class _OverBudgetBanner extends StatelessWidget {
  final List<Category> categories;
  const _OverBudgetBanner({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.expense.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.expense.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppTheme.expense, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Over Budget!',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.expense)),
                const SizedBox(height: 2),
                Text(
                  '${categories.length} categor${categories.length == 1 ? 'y has' : 'ies have'} crossed 90% of the limit',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final Category category;
  final int spent;
  final int? limit;
  final ValueChanged<int> onSetLimit;

  const _BudgetRow({
    required this.category,
    required this.spent,
    required this.limit,
    required this.onSetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = limit != null && limit! > 0 ? spent / limit! : 0.0;
    final barColor = ratio < 0.7
        ? AppTheme.income
        : ratio < 0.9
            ? AppTheme.warning
            : AppTheme.expense;
    final overBudget = limit != null && ratio > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: overBudget
              ? AppTheme.expense.withAlpha(80)
              : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(category.icon, size: 20, color: category.color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    if (overBudget)
                      const Text('OVER BUDGET',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.expense)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _editLimit(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    limit != null ? Money.format(limit!) : 'Set limit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: limit != null
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1),
              backgroundColor: AppTheme.bg.withAlpha(100),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Spent ${Money.format(spent)}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const Spacer(),
              if (limit != null)
                Text(
                  '${(ratio * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _editLimit(BuildContext context) {
    final ctrl = TextEditingController(
      text: limit != null ? Money.toEditString(limit!) : '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${category.label} Budget',
            style: const TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                prefixText: '₹ ',
                hintText: 'Monthly limit',
                filled: true,
                fillColor: AppTheme.bg.withAlpha(100),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Current spend: ${Money.format(spent)}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onSetLimit(0);
              Navigator.pop(ctx);
            },
            child: const Text('Remove',
                style: TextStyle(color: AppTheme.expense)),
          ),
          FilledButton(
            onPressed: () {
              final amount = Money.parseToMinor(ctrl.text);
              if (amount != null && amount > 0) {
                onSetLimit(amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Goals Tab ──

class _GoalsTab extends ConsumerStatefulWidget {
  const _GoalsTab();
  @override
  ConsumerState<_GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends ConsumerState<_GoalsTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetControllerProvider);
    final goals = state.goals;
    final monthExpenses = state.monthExpenses;
    final totalIncome = monthExpenses
        .where((e) => e.isIncome)
        .fold<int>(0, (s, e) => s + e.amountMinor);
    final totalExpense = monthExpenses
        .where((e) => !e.isIncome)
        .fold<int>(0, (s, e) => s + e.amountMinor);
    final monthlySavings = totalIncome - totalExpense;

    return Scaffold(
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flag_outlined,
                      size: 48,
                      color: AppTheme.textSecondary.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No savings goals yet',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Set a goal to start tracking your progress',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                ...goals.map((g) => _GoalCard(
                      goal: g,
                      monthlySavings: monthlySavings > 0 ? monthlySavings : null,
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addGoal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addGoal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final contributionCtrl = TextEditingController();
    DateTime deadline = DateTime.now().add(const Duration(days: 365));
    Category? selectedCat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('New Savings Goal',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _sheetField(nameCtrl, 'Goal Name', 'e.g. Emergency Fund'),
              const SizedBox(height: 12),
              _sheetField(targetCtrl, 'Target Amount', '0.00',
                  prefix: '₹ ', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _sheetField(contributionCtrl, 'Initial Contribution (optional)',
                  '0.00',
                  prefix: '₹ ', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  const Text('Deadline',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setDialogState(() => deadline = d);
                      }
                    },
                    child: Text(
                      '${deadline.day}/${deadline.month}/${deadline.year}',
                      style:
                          const TextStyle(color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final target = Money.parseToMinor(targetCtrl.text);
                  if (nameCtrl.text.trim().isEmpty || target == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                          content: Text('Enter name and target')),
                    );
                    return;
                  }
                  final initial =
                      Money.parseToMinor(contributionCtrl.text) ?? 0;
                  ref
                      .read(budgetControllerProvider.notifier)
                      .addGoal(Goal(
                        name: nameCtrl.text.trim(),
                        targetAmount: target,
                        currentAmount: initial,
                        deadline: deadline,
                        category: selectedCat,
                      ));
                  Navigator.of(ctx).pop();
                },
                child: const Text('Create Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    String hint, {
    String? prefix,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: AppTheme.textSecondary.withAlpha(120)),
              prefixText: prefix,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final Goal goal;
  final int? monthlySavings;
  const _GoalCard({required this.goal, this.monthlySavings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pct = (goal.progress * 100).round();
    final remainingLabel = goal.monthlyTarget > 0
        ? '${Money.format(goal.monthlyTarget)}/mo needed'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (goal.category ?? Category.other)
                      .color
                      .withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                    (goal.category ?? Category.other).icon,
                    color: (goal.category ?? Category.other).color,
                    size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      '${goal.daysRemaining} days remaining',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ── Circular Progress ──
          SizedBox(
            height: 100,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: goal.progress.clamp(0, 1),
                        strokeWidth: 8,
                        backgroundColor: AppTheme.bg.withAlpha(100),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          goal.progress >= 1
                              ? AppTheme.income
                              : goal.progress >= 0.7
                                  ? AppTheme.warning
                                  : AppTheme.primary,
                        ),
                      ),
                      Center(
                        child: Text(
                          '$pct%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            fontFeatures: [
                              FontFeature.tabularFigures()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _statRow('Saved', Money.format(goal.currentAmount),
                          AppTheme.income),
                      const SizedBox(height: 6),
                      _statRow('Target', Money.format(goal.targetAmount),
                          AppTheme.textSecondary),
                      if (remainingLabel != null) ...[
                        const SizedBox(height: 6),
                        _statRow('Need', remainingLabel, AppTheme.accent),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (monthlySavings != null && goal.progress < 1) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.primary.withAlpha(40)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.savings_outlined,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Monthly savings: ${Money.format(monthlySavings!)}',
                      style: const TextStyle(
                          fontSize: 13, color: AppTheme.textPrimary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _contribute(context, ref),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12)),
                    child: const Text('Add',
                        style: TextStyle(
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _contribute(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Contribution',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: 'Amount',
            filled: true,
            fillColor: AppTheme.bg.withAlpha(100),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.border),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final amt = Money.parseToMinor(ctrl.text);
              if (amt != null && amt > 0 && goal.id != null) {
                ref
                    .read(budgetControllerProvider.notifier)
                    .contributeToGoal(goal.id!, amt);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }
}

// ── Chart Tab ──

class _ChartTab extends ConsumerWidget {
  const _ChartTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetControllerProvider);
    final comparisons = state.categoryComparisons;

    if (comparisons.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 48,
                color: AppTheme.textSecondary.withAlpha(100)),
            const SizedBox(height: 16),
            const Text('No budget data yet',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Set category budgets to see comparison',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Budget vs Actual',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _legend(Icons.square, 'Budget', AppTheme.primary),
                  const SizedBox(width: 16),
                  _legend(Icons.square, 'Spent', AppTheme.warning),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: comparisons.length * 48.0,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comparisons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final entry = comparisons[i];
                    final cat = entry.key;
                    final spent = entry.value.$1;
                    final limit = entry.value.$2;

                    return _CategoryBar(
                      category: cat,
                      spent: spent,
                      limit: limit ?? 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(200),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monthly Summary',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _summaryRow('Total Budgeted',
                  Money.format(state.totalBudgeted), AppTheme.primary),
              const SizedBox(height: 8),
              _summaryRow('Total Spent', Money.format(state.totalSpent),
                  AppTheme.warning),
              const Divider(
                  height: 20, color: AppTheme.border),
              _summaryRow(
                'Remaining',
                Money.format(state.totalBudgeted - state.totalSpent),
                state.totalSpent <= state.totalBudgeted
                    ? AppTheme.income
                    : AppTheme.expense,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _summaryRow(String label, String value, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: color)),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final Category category;
  final int spent;
  final int limit;

  const _CategoryBar({
    required this.category,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = [limit, spent].reduce((a, b) => a > b ? a : b);
    final budgetWidth = maxVal > 0 ? limit / maxVal : 0.0;
    final spentWidth = maxVal > 0 ? spent / maxVal : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(category.icon, size: 14, color: category.color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(category.label,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ),
            Text(
              '${Money.format(spent)} / ${limit > 0 ? Money.format(limit) : '—'}',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 16, color: AppTheme.bg.withAlpha(80)),
              if (budgetWidth > 0)
                FractionallySizedBox(
                  widthFactor: budgetWidth.clamp(0, 1),
                  child: Container(
                    height: 16,
                    color: AppTheme.primary.withAlpha(60),
                  ),
                ),
              if (spentWidth > 0)
                FractionallySizedBox(
                  widthFactor: spentWidth.clamp(0, 1),
                  child: Container(
                    height: 16,
                    color: (spent > limit
                            ? AppTheme.expense
                            : AppTheme.warning)
                        .withAlpha(180),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
