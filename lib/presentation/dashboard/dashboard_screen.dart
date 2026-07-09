import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/coins/coin_controller.dart';
import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/expense.dart';
import '../../domain/models/goal.dart';
import '../expense/expense_form_screen.dart';
import '../history/history_screen.dart';
import '../khata/khata_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../budget/budget_screen.dart';
import '../shared/quick_expense_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _coinVaultKey = GlobalKey();

  void _scrollToCoinVault() {
    final ctx = _coinVaultKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinState = ref.watch(coinControllerProvider);
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    final monthLabel = '${months[now.month]} ${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 28,
                  height: 28,
                ),
                const SizedBox(width: 10),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.warningGlass,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                  onTap: _scrollToCoinVault,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFD700),
                              Color(0xFFDAA520),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text('¢',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('${coinState.balance}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppTheme.warning)),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppTheme.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          children: [
            const _PremiumSummary(),
            const SizedBox(height: 14),
            const _BalanceCard(),
            const SizedBox(height: 14),
            Consumer(builder: (context, ref, _) {
              final wasted = ref.watch(wastedTotalProvider);
              final state = ref.watch(historyControllerProvider);
              final total = state.totalExpense;
              return _SpendingMood(totalExpense: total, wasted: wasted);
            }),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BudgetScreen()),
              ),
              child: const _BudgetCard(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _QuickChip(
                  icon: Icons.flag_outlined,
                  label: 'Goals',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BudgetScreen(initialTab: 1)),
                  ),
                ),
                const SizedBox(width: 8),
                _QuickChip(
                  icon: Icons.tune_rounded,
                  label: 'Set Budget',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Consumer(builder: (context, ref, _) {
              final khata = ref.watch(khataControllerProvider);
              return _KhataSummaryCard(
                owed: khata.totalYouAreOwed,
                owe: khata.totalYouOwe,
                entryCount: khata.entries.length,
              );
            }),
            const SizedBox(height: 14),
            const _DailyTip(),
            const SizedBox(height: 14),
            const _SmartInsights(),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final state = ref.watch(historyControllerProvider);
              final monthlyBudget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
              final expenses = state.days.expand((d) => d.expenses).toList();
              return _SpendingStreakCard(
                monthExpenses: expenses,
                monthlyBudget: monthlyBudget,
                daysInMonth: DateTime.now().day,
              );
            }),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final historyState = ref.watch(historyControllerProvider);
              final monthlyBudget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
              final goals = ref.watch(budgetControllerProvider).goals;
              final wasted = ref.watch(wastedTotalProvider);
              final sortedCats = ref.watch(categoryTotalsProvider);
              return _FinancialHealthCard(
                totalIncome: historyState.totalIncome,
                totalExpense: historyState.totalExpense,
                monthlyBudget: monthlyBudget,
                goals: goals,
                wasted: wasted,
                categoryCount: sortedCats.length,
                txCount: historyState.days.fold<int>(0, (s, d) => s + d.expenses.length),
              );
            }),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final coinState = ref.watch(coinControllerProvider);
              return _CoinVaultCard(key: _coinVaultKey, coinState: coinState);
            }),
            const SizedBox(height: 14),
            Consumer(builder: (context, ref, _) {
              final coinState = ref.watch(coinControllerProvider);
              return _PremiumTeaserCard(coinBalance: coinState.balance);
            }),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final sortedCats = ref.watch(categoryTotalsProvider);
              final total = ref.watch(historyControllerProvider).totalExpense;
              if (sortedCats.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spending Breakdown', style: AppTheme.sectionTitle),
                  const SizedBox(height: 12),
                  ...sortedCats.map((e) => _CategoryBar(
                      category: e.key, amount: e.value, total: total)),
                ],
              );
            }),
            const SizedBox(height: 20),
            Consumer(builder: (context, ref, _) {
              final expenses = ref.watch(monthExpensesProvider);
              final recent = expenses.reversed.take(5).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              );
            }),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'scan',
            backgroundColor: AppTheme.accent,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const QrScannerScreen()),
            ),
            tooltip: 'Scan & Add',
            child: const Icon(Icons.qr_code_scanner_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'quick_entry',
            onPressed: () => QuickExpenseSheet.show(context),
            tooltip: 'Quick Entry',
            child: const Icon(Icons.add),
          ),
        ],
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

}class _PremiumSummary extends ConsumerWidget {
  const _PremiumSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final total = state.totalExpense;
    final income = state.totalIncome;
    final count = state.days.fold<int>(0, (s, d) => s + d.expenses.length);

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
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _StatChip(
                  icon: Icons.receipt, label: '$count transactions'),
              if (total > 0)
                _StatChip(
                    icon: Icons.trending_up,
                    label: 'Avg ${Money.format(total ~/ count)}'),
              if (income > 0)
                _StatChip(
                    icon: Icons.savings,
                    label: 'Net ${Money.format(income - total)}',
                    isIncome: (income - total) >= 0),
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

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final income = state.totalIncome;
    final spent = state.totalExpense;
    final netFlow = income - spent;
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
              const Text('Account', style: AppTheme.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: netFlow >= 0 ? AppTheme.incomeGlass : AppTheme.expenseGlass,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Net ${netFlow >= 0 ? '+' : ''}${Money.format(netFlow)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: netFlow >= 0 ? AppTheme.income : AppTheme.expense,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _BalanceLabel(
                      label: 'Income',
                      amount: Money.format(income),
                      color: AppTheme.income)),
              const SizedBox(width: 10),
              Expanded(
                  child: _BalanceLabel(
                      label: 'Spent',
                      amount: Money.format(spent),
                      color: AppTheme.expense)),
              const SizedBox(width: 10),
              Expanded(
                  child: _BalanceLabel(
                      label: 'Balance',
                      amount: Money.format(netFlow),
                      color: netFlow >= 0 ? AppTheme.income : AppTheme.expense)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends ConsumerWidget {
  const _BudgetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
    final spent = ref.watch(historyControllerProvider).totalExpense;
    final remaining = ref.watch(budgetRemainingProvider);
    final progress = ref.watch(budgetProgressProvider);
    final dailyAvg = ref.watch(dailyAverageProvider);

    if (budget <= 0) return const SizedBox.shrink();
    final overBudget = spent > budget;
    final pct = (progress * 100).round().clamp(0, 200);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: overBudget ? AppTheme.expense.withAlpha(60) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: overBudget ? AppTheme.expenseGlass : AppTheme.primaryGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  overBudget ? Icons.gpp_bad : Icons.pie_chart_rounded,
                  size: 16,
                  color: overBudget ? AppTheme.expense : AppTheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text('Monthly Budget', style: AppTheme.sectionTitle),
              const Spacer(),
              Text(
                Money.format(budget),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: overBudget ? AppTheme.expense : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1),
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                overBudget ? AppTheme.expense : AppTheme.primary,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${Money.format(spent)} spent',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ),
              if (!overBudget)
                Text(
                  '${Money.format(remaining)} left',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.income,
                  ),
                )
              else
                Text(
                  '${Money.format(-remaining)} over!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.expense,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (dailyAvg > 0) ...[
            Row(
              children: [
                Icon(Icons.show_chart, size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Daily avg: ${Money.format(dailyAvg)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Text(
                  '$pct% used',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: pct > 80 ? AppTheme.expense : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SmartInsights extends ConsumerWidget {
  const _SmartInsights();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final total = state.totalExpense;
    final wasted = ref.watch(wastedTotalProvider);
    final essential = total - wasted;
    final budgetProgress = ref.watch(budgetProgressProvider);
    final spendingScore = ref.watch(spendingScoreProvider);
    final netFlow = state.totalIncome - state.totalExpense;
    final monthlyBudget = ref.watch(settingsControllerProvider).profile.monthlyBudget;
    final txCount = state.days.fold<int>(0, (s, d) => s + d.expenses.length);

    final scoreLabel = spendingScore >= 90 ? 'Excellent' : spendingScore >= 75 ? 'Good' : spendingScore >= 50 ? 'Fair' : 'Needs Attention';
    final scoreColor = spendingScore >= 90 ? AppTheme.income : spendingScore >= 75 ? AppTheme.primary : spendingScore >= 50 ? AppTheme.warning : AppTheme.expense;
    final wastePct = total > 0 ? (wasted / total * 100).round().clamp(0, 100) : 0;
    final essentialPct = (100 - wastePct).clamp(1, 100);

    String buildPrimaryInsight() {
      if (total == 0) return 'No spending yet this month. Start tracking to get insights!';
      final msgs = <String>[];
      if (monthlyBudget > 0) {
        if (budgetProgress >= 1.0) {
          msgs.add('You\'ve exceeded your monthly budget.');
        } else if (budgetProgress >= 0.75) {
          msgs.add('You\'ve used ${(budgetProgress * 100).round()}% of your budget.');
        } else {
          msgs.add('On track with ${((1 - budgetProgress) * 100).round()}% budget remaining.');
        }
      }
      if (wastePct > 50) {
        msgs.add('$wastePct% of spending is discretionary.');
      } else if (essentialPct > 70) {
        msgs.add('$essentialPct% goes to essentials — good discipline.');
      }
      if (netFlow < 0) {
        msgs.add('Spending exceeds income by ${Money.format(-netFlow)}.');
      } else if (netFlow > 0 && total > 0) {
        msgs.add('Saving ${Money.format(netFlow)} this month.');
      }
      return msgs.isEmpty ? 'Balanced spending this month.' : msgs.join(' ');
    }

    String buildTip() {
      if (total == 0) return 'Set a monthly budget in Settings to track your limits.';
      if (monthlyBudget <= 0) return 'Set a monthly budget in Settings to stay on track.';
      if (budgetProgress >= 0.9) return 'You\'re close to your budget limit! Consider pausing non-essential spending.';
      if (wastePct > 60) return 'Try cutting discretionary spending to save more.';
      if (netFlow < 0) return 'Look for ways to reduce expenses or increase income.';
      if (txCount > 30) return 'You\'re tracking frequently — great habit!';
      return 'Keep up the good financial discipline!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
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
                  color: scoreColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.auto_awesome, size: 16, color: scoreColor),
              ),
              const SizedBox(width: 10),
              const Text('Smart Insights', style: AppTheme.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed, size: 13, color: scoreColor),
                    const SizedBox(width: 4),
                    Text('Score $spendingScore',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scoreColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _ScoreRing(score: spendingScore, label: scoreLabel),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InsightTile(
                      icon: Icons.insights,
                      text: buildPrimaryInsight(),
                    ),
                    const SizedBox(height: 8),
                    _InsightTile(
                      icon: Icons.tips_and_updates,
                      text: buildTip(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (total > 0) ...[
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
                    label: 'Discretionary',
                    amount: Money.format(wasted)),
              ],
            ),
          ],
        ],
      ),
    );
  }

}

class _ScoreRing extends StatelessWidget {
  final int score;
  final String label;
  const _ScoreRing({required this.score, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 5,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                score >= 75 ? AppTheme.income : score >= 50 ? AppTheme.warning : AppTheme.expense,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppTheme.textPrimary)),
              Text(label,
                  style: TextStyle(fontSize: 8, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InsightTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.4)),
        ),
      ],
    );
  }
}

class _SpendingStreakCard extends StatelessWidget {
  final List<Expense> monthExpenses;
  final int monthlyBudget;
  final int daysInMonth;
  const _SpendingStreakCard({
    required this.monthExpenses,
    required this.monthlyBudget,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final dailyBudget = monthlyBudget > 0 ? monthlyBudget ~/ daysInMonth : 0;
    if (dailyBudget <= 0) return const SizedBox.shrink();

    final dailyTotals = <DateTime, int>{};
    for (final e in monthExpenses) {
      if (e.isIncome) continue;
      final day = DateTime(e.localDate.year, e.localDate.month, e.localDate.day);
      dailyTotals.update(day, (v) => v + e.amountMinor, ifAbsent: () => e.amountMinor);
    }

    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < daysInMonth; i++) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      if (day.month != today.month) break;
      final spent = dailyTotals[day] ?? 0;
      if (spent <= dailyBudget) {
        streak++;
      } else {
        break;
      }
    }

    if (streak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.warningGlass,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_fire_department,
                size: 20, color: AppTheme.warning),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$streak day${streak == 1 ? '' : 's'} streak!',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  streak == 1
                      ? 'You stayed under budget yesterday'
                      : 'Consecutive days under budget',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.warningGlass,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('🔥 $streak',
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.warning)),
          ),
        ],
      ),
    );
  }
}

const _dailyTips = [
  'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
  'A small daily coffee costs ₹3000+ a year. Brew at home!',
  'Save first, spend later — pay yourself before bills.',
  'Track every expense for 30 days. You\'ll spot leaks instantly.',
  'An emergency fund of 3-6 months of expenses is your safety net.',
  'Round up purchases and save the change. It adds up!',
  'Cook at home 3 more times a week. Save ₹2000+ monthly.',
  'Unused subscriptions? Cancel them. That\'s free money.',
  'Wait 24 hours before buying anything over ₹1000.',
  'Pay credit card bills in full. Interest is wealth killer.',
  'Set a no-spend day each week. Your wallet will thank you.',
  'Buy generic brands. Same quality, half the price.',
  'Review your recurring bills yearly. Negotiate better rates.',
  'Use public transport twice a week. Save fuel + stress.',
  'Sell things you haven\'t used in 6 months. Declutter + earn.',
  'A ₹500 monthly SIP in index funds = ₹1L+ in 10 years.',
  'Don\'t shop when hungry, angry, or bored. Emotional spending hurts.',
  'Cashback apps are great, but don\'t buy just for the cashback.',
  'Your biggest wealth builder is your income. Invest in skills.',
  'Compare insurance plans yearly. Loyalty rarely pays.',
  'Set a savings goal with a photo. Visual motivation works.',
  'Repay high-interest debt first. It\'s an emergency.',
  'Use the library instead of buying books. Free knowledge.',
  'Bulk cook on weekends. Save time + money on weeknights.',
  'Track your net worth monthly, not daily. Focus on trends.',
];

class _SpendingMood extends StatelessWidget {
  final int totalExpense;
  final int wasted;
  const _SpendingMood({required this.totalExpense, required this.wasted});

  @override
  Widget build(BuildContext context) {
    final wastePct = totalExpense > 0 ? wasted / totalExpense : 0.0;
    String emoji;
    String message;
    Color color;
    if (totalExpense == 0) {
      emoji = '\u{1F60A}';
      message = 'No spending yet. You\'re doing great!';
      color = AppTheme.income;
    } else if (wastePct < 0.2) {
      emoji = '\u{1F929}';
      message = 'Smart spender! Mostly on essentials.';
      color = AppTheme.income;
    } else if (wastePct < 0.4) {
      emoji = '\u{1F60A}';
      message = 'Pretty balanced. Keep it up!';
      color = AppTheme.primary;
    } else if (wastePct < 0.6) {
      emoji = '\u{1F914}';
      message = 'Half on wants. Try cutting back a bit.';
      color = AppTheme.warning;
    } else if (wastePct < 0.8) {
      emoji = '\u{1F622}';
      message = 'Most spending is on wants. Pause and review!';
      color = AppTheme.warning;
    } else {
      emoji = '\u{1F480}';
      message = 'Almost all on non-essentials! Time for a reset.';
      color = AppTheme.expense;
    }
    final saved = totalExpense - wasted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(12), color.withAlpha(4)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color)),
                if (totalExpense > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\u{2714}\u{FE0F} ${Money.format(saved)} on essentials  \u{274C} ${Money.format(wasted)} on wants',
                    style: TextStyle(fontSize: 11, color: color.withAlpha(180)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyTip extends ConsumerWidget {
  const _DailyTip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tipIndex = dayOfYear % _dailyTips.length;
    final tip = _dailyTips[tipIndex];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accent.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_outline,
                size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Daily Tip',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent,
                            letterSpacing: 0.5)),
                    const Spacer(),
                    Text('\u{1F4C5} Day ${now.day}',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.accent.withAlpha(150))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface.withAlpha(150),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right,
                  size: 14, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialHealthCard extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;
  final int monthlyBudget;
  final List<Goal> goals;
  final int wasted;
  final int categoryCount;
  final int txCount;

  const _FinancialHealthCard({
    required this.totalIncome,
    required this.totalExpense,
    required this.monthlyBudget,
    required this.goals,
    required this.wasted,
    required this.categoryCount,
    required this.txCount,
  });

  @override
  Widget build(BuildContext context) {
    final savingsRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0, 100).round()
        : 0;
    final budgetRate = monthlyBudget > 0
        ? ((monthlyBudget - totalExpense) / monthlyBudget * 100).clamp(0, 100).round()
        : 100;
    final goalRate = goals.isNotEmpty
        ? (goals.fold<double>(0, (s, g) => s + g.progress) / goals.length * 100).round()
        : 0;
    final wasteRate = totalExpense > 0
        ? ((totalExpense - wasted) / totalExpense * 100).clamp(0, 100).round()
        : 100;
    final consistRate = (txCount.clamp(0, 30) / 30 * 100).round();

    final metrics = [
      _HealthMetric('Savings Rate', savingsRate, Icons.trending_up,
          '$savingsRate% of income saved'),
      _HealthMetric('Budget Adherence', budgetRate, Icons.account_balance_wallet,
          '$budgetRate% budget remaining'),
      _HealthMetric('Goal Progress', goalRate, Icons.flag,
          '$goalRate% of goals on track'),
      _HealthMetric('Essential Spend', wasteRate, Icons.shopping_cart,
          '$wasteRate% on essentials'),
      _HealthMetric('Tracking Habit', consistRate, Icons.calendar_month,
          '$txCount entries this month'),
    ];

    final overall =
        (metrics.fold<int>(0, (s, m) => s + m.score) / metrics.length).round();

    String healthLabel;
    Color healthColor;
    if (overall >= 80) {
      healthLabel = 'Excellent';
      healthColor = AppTheme.income;
    } else if (overall >= 60) {
      healthLabel = 'Good';
      healthColor = AppTheme.primary;
    } else if (overall >= 40) {
      healthLabel = 'Fair';
      healthColor = AppTheme.warning;
    } else {
      healthLabel = 'Needs Work';
      healthColor = AppTheme.expense;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: healthColor.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: healthColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.favorite, size: 16, color: healthColor),
              ),
              const SizedBox(width: 10),
              const Text('Financial Health', style: AppTheme.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: healthColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$overall',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: healthColor)),
                    const SizedBox(width: 4),
                    Text(healthLabel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: healthColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metrics.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HealthMetricRow(metric: m, total: metrics.length),
              )),
          const SizedBox(height: 4),
          _buildTip(overall, savingsRate, budgetRate, goalRate),
        ],
      ),
    );
  }

  Widget _buildTip(int overall, int savings, int budget, int goals) {
    String tip;
    if (overall >= 80) {
      tip = 'Great shape! Keep tracking daily to maintain your health.';
    } else if (savings < 20) {
      tip = 'Try to save at least 20% of your income each month.';
    } else if (budget < 30) {
      tip = 'You\'re close to your budget limit. Consider cutting non-essentials.';
    } else if (goals < 30) {
      tip = 'Boost your goal contributions to stay on track.';
    } else if (totalExpense > totalIncome) {
      tip = 'Expenses exceed income. Review your spending habits.';
    } else {
      tip = 'Keep building good financial habits!';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: overall >= 60
            ? AppTheme.income.withAlpha(15)
            : AppTheme.warning.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overall >= 60
              ? AppTheme.income.withAlpha(40)
              : AppTheme.warning.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          Icon(
            overall >= 60 ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: overall >= 60 ? AppTheme.income : AppTheme.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(tip,
                style: TextStyle(
                    fontSize: 12,
                    color: overall >= 60
                        ? AppTheme.income
                        : AppTheme.warning)),
          ),
        ],
      ),
    );
  }
}

class _HealthMetric {
  final String label;
  final int score;
  final IconData icon;
  final String subtitle;
  const _HealthMetric(this.label, this.score, this.icon, this.subtitle);
}

class _HealthMetricRow extends StatelessWidget {
  final _HealthMetric metric;
  final int total;
  const _HealthMetricRow({required this.metric, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = metric.score >= 70
        ? AppTheme.income
        : metric.score >= 40
            ? AppTheme.warning
            : AppTheme.expense;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(metric.icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(metric.label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
            Text('${metric.score}%',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: metric.score / 100.0,
            minHeight: 6,
            backgroundColor: AppTheme.bg.withAlpha(100),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CoinVaultCard extends StatelessWidget {
  final CoinState coinState;
  const _CoinVaultCard({super.key, required this.coinState});

  @override
  Widget build(BuildContext context) {
    final streakBonus = (coinState.loginStreak * 5).clamp(5, 50);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.warning.withAlpha(30),
            AppTheme.cardSurface.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.warning.withAlpha(60)),
      ),
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
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 16, color: AppTheme.warning),
              ),
              const SizedBox(width: 10),
              const Text('CoinVault', style: AppTheme.sectionTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warningGlass,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFFD700),
                            Color(0xFFDAA520),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Text('¢',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${coinState.balance}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.warning)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EarnTile(
                  icon: Icons.login,
                  label: 'Login streak',
                  value: 'Day ${coinState.loginStreak}',
                  bonus: '+$streakBonus',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EarnTile(
                  icon: Icons.receipt,
                  label: 'Today',
                  value: '${coinState.transactionsToday}/10 tx',
                  bonus: coinState.transactionsToday < 10 ? '+2 each' : 'maxed',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _EarnTile(
                  icon: Icons.trending_down,
                  label: 'Budget streak',
                  value: '${coinState.budgetStreak} day${coinState.budgetStreak == 1 ? '' : 's'}',
                  bonus: coinState.budgetStreak >= 7
                      ? '🔥 ${coinState.budgetStreak >= 30 ? "200" : "50"}'
                      : '+5/day',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _EarnTile(
                  icon: Icons.auto_awesome,
                  label: 'Premium AI',
                  value: 'Coming soon',
                  bonus: 'unlock',
                  isLocked: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _CoinHistorySheet.show(context),
              icon: const Icon(Icons.history, size: 16),
              label: const Text('View History',
                  style: TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 40),
                side: BorderSide(color: AppTheme.warning.withAlpha(80)),
                foregroundColor: AppTheme.warning,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinHistorySheet extends ConsumerWidget {
  const _CoinHistorySheet();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _CoinHistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(coinControllerProvider);
    final history = state.history.reversed.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.history, size: 20, color: AppTheme.warning),
                const SizedBox(width: 8),
                const Text('Coin History',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warningGlass,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Balance: ${state.balance}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warning)),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.border),
          if (history.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_outlined,
                        size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: 12),
                    Text('No coins earned yet',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    SizedBox(height: 4),
                    Text('Add transactions and log in daily to earn coins',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                controller: scrollCtrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: history.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppTheme.border),
                itemBuilder: (_, i) {
                  final tx = history[i];
                  final isPositive = tx.amount > 0;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPositive
                            ? AppTheme.incomeGlass
                            : AppTheme.expenseGlass,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        size: 18,
                        color: isPositive ? AppTheme.income : AppTheme.expense,
                      ),
                    ),
                    title: Text(tx.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.textPrimary)),
                    subtitle: Text(
                      '${tx.timestamp.day}/${tx.timestamp.month}/${tx.timestamp.year} ${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    trailing: Text(
                      '${isPositive ? '+' : ''}${tx.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: isPositive ? AppTheme.income : AppTheme.expense,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EarnTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String bonus;
  final bool isLocked;

  const _EarnTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.bonus,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked
            ? AppTheme.cardSurface.withAlpha(100)
            : AppTheme.cardGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked ? AppTheme.border : AppTheme.warning.withAlpha(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: isLocked
                      ? AppTheme.textSecondary
                      : AppTheme.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary)),
              ),
              if (isLocked)
                const Icon(Icons.lock_outline,
                    size: 12, color: AppTheme.textSecondary),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary)),
          Text('$bonus coins',
              style: TextStyle(
                  fontSize: 10,
                  color: isLocked
                      ? AppTheme.textSecondary.withAlpha(120)
                      : AppTheme.warning)),
        ],
      ),
    );
  }
}

class _PremiumTeaserCard extends StatelessWidget {
  final int coinBalance;
  const _PremiumTeaserCard({required this.coinBalance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accent.withAlpha(40),
            AppTheme.cardSurface.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.accent.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 16, color: AppTheme.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AI Analytics',
                        style: AppTheme.sectionTitle),
                    Text('Smart expense management',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGlass,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('PREMIUM',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _FeatureRow(
                    icon: Icons.psychology,
                    label: 'AI Spending Predictions',
                    locked: true),
                const SizedBox(height: 8),
                _FeatureRow(
                    icon: Icons.trending_up,
                    label: 'Smart Budget Recommendations',
                    locked: true),
                const SizedBox(height: 8),
                _FeatureRow(
                    icon: Icons.notifications_active,
                    label: 'Intelligent Bill Reminders',
                    locked: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withAlpha(100),
                    AppTheme.primary.withAlpha(100),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.accent.withAlpha(80)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open,
                      size: 14, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Coming soon — save coins to unlock',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool locked;
  const _FeatureRow({
    required this.icon,
    required this.label,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16,
            color: locked
                ? AppTheme.textSecondary.withAlpha(120)
                : AppTheme.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: locked
                      ? AppTheme.textSecondary.withAlpha(180)
                      : AppTheme.textPrimary)),
        ),
        Icon(
          locked ? Icons.lock_outline : Icons.check_circle,
          size: 14,
          color: locked ? AppTheme.textSecondary.withAlpha(100) : AppTheme.income,
        ),
      ],
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
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _edit(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardGlass,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit_outlined,
                      size: 14, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _delete(context, ref),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.expenseGlass,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 14, color: AppTheme.expense),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date, Category cat) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${date.day} ${months[date.month - 1]}  •  ${cat.label}';
}

class _KhataSummaryCard extends StatelessWidget {
  final int owed;
  final int owe;
  final int entryCount;
  const _KhataSummaryCard({
    required this.owed,
    required this.owe,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    if (entryCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const KhataScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.primary.withAlpha(50)),
          color: AppTheme.cardSurface.withAlpha(150),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Khata',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textSecondary)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _AmountChip(
                        label: 'Owed',
                        amount: owed,
                        color: AppTheme.income,
                      ),
                      const SizedBox(width: 12),
                      _AmountChip(
                        label: 'Owe',
                        amount: owe,
                        color: AppTheme.expense,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AmountChip extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _AmountChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        '$label ${amount > 0 ? Money.format(amount) : '₹0'}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
