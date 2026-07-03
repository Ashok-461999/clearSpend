import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/expense.dart';
import '../expense/expense_form_screen.dart';
import '../history/history_screen.dart';
import '../shared/quick_expense_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final monthExpenses = state.days.expand((d) => d.expenses).toList();

    final totalExpenses = state.totalExpense;
    final txCount = monthExpenses.length;
    final remaining = ref.watch(remainingBalanceProvider);
    final initialBalance =
        ref.watch(settingsControllerProvider).profile.initialBalance;
    final totalIncome = state.totalIncome;

    final catTotals = <Category, int>{};
    int wasted = 0;
    for (final e in monthExpenses) {
      if (e.isIncome) continue;
      catTotals.update(
          e.category, (v) => v + e.amountMinor, ifAbsent: () => e.amountMinor);
      if (!e.category.isEssential) {
        wasted += e.amountMinor;
      }
    }
    final sortedCats = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recent = monthExpenses.reversed.take(5).toList();
    final essential = totalExpenses - wasted;

    final now = DateTime.now();
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthLabel = '${months[now.month]} ${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.income,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('ClearSpend'),
              ],
            ),
            Text(monthLabel,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          children: [
            _PremiumSummary(total: totalExpenses, income: totalIncome, count: txCount),
            if (initialBalance > 0) ...[
              const SizedBox(height: 14),
              _BalanceCard(
                initialBalance: initialBalance,
                spent: totalExpenses,
                remaining: remaining,
              ),
            ],
            const SizedBox(height: 20),
            _InsightRow(essential: essential, wasted: wasted, total: totalExpenses),
            const SizedBox(height: 20),
            if (sortedCats.isNotEmpty) ...[
              Text('Spending Breakdown', style: AppTheme.sectionTitle),
              const SizedBox(height: 12),
              ...sortedCats.map((e) => _CategoryBar(
                  category: e.key, amount: e.value, total: totalExpenses)),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Activity', style: AppTheme.sectionTitle),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (recent.isEmpty)
              _buildEmptyState()
            else
              ...recent.map((e) => _TransactionRow(expense: e)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuickExpenseSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: AppTheme.textSecondary.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No expenses recorded',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text("Tap + to add your first expense",
              style: TextStyle(color: AppTheme.textSecondary.withAlpha(150), fontSize: 13)),
        ],
      ),
    );
  }
}

class _PremiumSummary extends StatelessWidget {
  final int total;
  final int income;
  final int count;
  const _PremiumSummary(
      {required this.total, required this.income, required this.count});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text('This Month',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expenses',
                        style: TextStyle(
                            color: AppTheme.textSecondary.withAlpha(180),
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(Money.format(total),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                  ],
                ),
              ),
              Container(width: 1, height: 48, color: AppTheme.border),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Income',
                        style: TextStyle(
                            color: AppTheme.textSecondary.withAlpha(180),
                            fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(Money.format(income),
                        style: const TextStyle(
                            color: AppTheme.income,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                  icon: Icons.receipt, label: '$count transactions'),
              const SizedBox(width: 10),
              if (total > 0)
                _StatChip(
                    icon: Icons.trending_up,
                    label: 'Avg ${Money.format(total ~/ count)}'),
              if (income > 0) ...[
                const SizedBox(width: 10),
                _StatChip(
                    icon: Icons.savings,
                    label: 'Net ${Money.format(income - total)}',
                    isIncome: (income - total) >= 0),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isIncome;
  const _StatChip(
      {required this.icon, required this.label, this.isIncome = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13,
              color: isIncome ? AppTheme.income : AppTheme.expense),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final int essential;
  final int wasted;
  final int total;
  const _InsightRow(
      {required this.essential, required this.wasted, required this.total});

  @override
  Widget build(BuildContext context) {
    final wastePct = total > 0 ? (wasted / total * 100).round() : 0;
    final essentialPct = 100 - wastePct;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('Spending Overview', style: AppTheme.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: wastePct > 50
                      ? AppTheme.expenseGlass
                      : AppTheme.incomeGlass,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$wastePct% wasted',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: wastePct > 50
                            ? AppTheme.expense
                            : AppTheme.income)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: essentialPct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.income, Color(0xFF16A34A)],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: wastePct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.expense, Color(0xFFDC2626)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(
                  color: AppTheme.income,
                  label: 'Essential',
                  amount: Money.format(essential)),
              const Spacer(),
              _LegendDot(
                  color: AppTheme.expense,
                  label: 'Wasted',
                  amount: Money.format(wasted)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  const _LegendDot(
      {required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(width: 6),
        Text(amount,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final Category category;
  final int amount;
  final int total;
  const _CategoryBar(
      {required this.category, required this.amount, required this.total});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? amount / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: category.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(category.icon, size: 16, color: category.color),
                ),
                const SizedBox(width: 12),
                Text(category.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                Text(Money.format(amount),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                const SizedBox(width: 6),
                Text('(${(fraction * 100).round()}%)',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: category.color.withAlpha(20),
                valueColor: AlwaysStoppedAnimation<Color>(category.color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final int initialBalance;
  final int spent;
  final int remaining;
  const _BalanceCard(
      {required this.initialBalance,
      required this.spent,
      required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              const Text('Balance Overview', style: AppTheme.sectionTitle),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _BalanceLabel(
                      label: 'Initial',
                      amount: Money.format(initialBalance),
                      color: AppTheme.primary)),
              const SizedBox(width: 10),
              Expanded(
                  child: _BalanceLabel(
                      label: 'Spent',
                      amount: Money.format(spent),
                      color: AppTheme.expense)),
              const SizedBox(width: 10),
              Expanded(
                  child: _BalanceLabel(
                      label: 'Remaining',
                      amount: Money.format(remaining),
                      color: remaining >= 0 ? AppTheme.income : AppTheme.expense)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceLabel extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  const _BalanceLabel(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color.withAlpha(180))),
          const SizedBox(height: 4),
          Text(amount,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _TransactionRow extends ConsumerWidget {
  final Expense expense;
  const _TransactionRow({required this.expense});

  void _edit(BuildContext context, WidgetRef ref) {
    ref.read(expenseFormControllerProvider.notifier).loadForEdit(expense);
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const ExpenseFormScreen()));
  }

  Future<bool> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${expense.isIncome ? 'income' : 'expense'}?',
            style:
                const TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: Text(
            'Remove ${expense.notes ?? expense.category.label} of ${Money.format(expense.amountMinor)}?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.expense,
                minimumSize: const Size(80, 40)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(expenseRepositoryProvider).delete(expense.id!);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) => _delete(context, ref),
      child: InkWell(
        onTap: () => _edit(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(180),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: expense.category.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(expense.category.icon,
                    color: expense.category.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.notes ?? expense.category.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(_formatDate(expense.localDate, expense.category),
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${expense.isIncome ? '+' : '-'}${Money.format(expense.amountMinor)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: expense.isIncome
                        ? AppTheme.income
                        : AppTheme.expense),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, Category cat) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}  •  ${cat.label}';
  }
}
