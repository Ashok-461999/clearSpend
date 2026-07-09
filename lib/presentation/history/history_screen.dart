import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/history/history_controller.dart';
import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/date_range.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/expense.dart';
import '../expense/expense_form_screen.dart';
import '../shared/amount_text.dart';
import '../shared/category_chip.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  const HistoryScreen._internal() : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const HistoryBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          ref.read(expenseFormControllerProvider.notifier).reset();
          await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpenseFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined,
                size: 48, color: AppTheme.textSecondary.withAlpha(100)),
          ),
          const SizedBox(height: 16),
          const Text('No expenses yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              ref.read(expenseFormControllerProvider.notifier).reset();
              if (context.mounted) {
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExpenseFormScreen()));
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add your first expense'),
            style: FilledButton.styleFrom(minimumSize: const Size(220, 48)),
          ),
        ],
      ),
    );
  }
}

class _RangeFilterChips extends StatelessWidget {
  final HistoryState state;
  final HistoryController notifier;
  const _RangeFilterChips({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final type in DateRangeType.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: () {
                      if (type == DateRangeType.custom) {
                        _pickCustomRange(context);
                      } else {
                        notifier.setRangeType(type);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: state.rangeType == type
                            ? AppTheme.primaryGlass
                            : AppTheme.cardGlass,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: state.rangeType == type
                              ? AppTheme.primary.withAlpha(80)
                              : AppTheme.border,
                        ),
                      ),
                      child: Text(_chipLabel(type),
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: state.rangeType == type
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: state.rangeType == type
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _chipLabel(DateRangeType type) {
    switch (type) {
      case DateRangeType.today: return 'Today';
      case DateRangeType.week: return 'Week';
      case DateRangeType.month: return 'Month';
      case DateRangeType.year: return 'Year';
      case DateRangeType.custom: return 'Custom';
    }
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = DateTime.now();
    final initial = state.customStart != null && state.customEnd != null
        ? DateTimeRange(start: state.customStart!, end: state.customEnd!)
        : DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now.add(const Duration(days: 1)));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      notifier.setCustomRange(
          picked.start, picked.end.add(const Duration(days: 1)));
    }
  }
}

class _RangeHeader extends StatelessWidget {
  final HistoryState state;
  final HistoryController notifier;
  const _RangeHeader({required this.state, required this.notifier});

  bool get _isMonth => state.rangeType == DateRangeType.month;

  String _rangeLabel() {
    switch (state.rangeType) {
      case DateRangeType.today:
        return 'Today';
      case DateRangeType.week:
        final b = weekBounds();
        final e = b.end.subtract(const Duration(days: 1));
        const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        if (b.start.month == e.month) return '${m[b.start.month]} ${b.start.day} - ${e.day}';
        return '${m[b.start.month]} ${b.start.day} - ${m[e.month]} ${e.day}';
      case DateRangeType.month:
        const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${m[state.month]} ${state.year}';
      case DateRangeType.year:
        return '${state.year}';
      case DateRangeType.custom:
        final end = state.customEnd!.subtract(const Duration(days: 1));
        const m = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${m[state.customStart!.month]} ${state.customStart!.day} - ${m[end.month]} ${end.day}, ${end.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          if (_isMonth)
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 22),
              onPressed: notifier.previousMonth,
              style: IconButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary),
            ),
          Expanded(
            child: Text(_rangeLabel(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
          if (_isMonth)
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 22),
              onPressed: notifier.nextMonth,
              style: IconButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary),
            ),
          const SizedBox(width: 4),
          if (state.totalIncome > 0) ...[
            AmountText(minor: state.totalIncome, size: 14, isExpense: false),
            const SizedBox(width: 8),
          ],
          AmountText(minor: state.totalExpense, size: 16, isExpense: true),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _CategoryFilter extends ConsumerWidget {
  final HistoryState state;
  final HistoryController notifier;
  const _CategoryFilter({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => notifier.setCategory(null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: state.categoryFilter == null
                        ? AppTheme.primaryGlass
                        : AppTheme.cardGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: state.categoryFilter == null
                          ? AppTheme.primary.withAlpha(80)
                          : AppTheme.border,
                    ),
                  ),
                  child: Text('All',
                      style: TextStyle(
                          fontWeight: state.categoryFilter == null
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: state.categoryFilter == null
                              ? AppTheme.primary
                              : AppTheme.textSecondary)),
                ),
              ),
            ),
            ...Category.values.map((c) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: CategoryChip(
                    category: c,
                    selected: state.categoryFilter == c,
                    onTap: () => notifier.setCategory(c),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  final DayGroup day;
  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    final weekday = DateTime(day.date.year, day.date.month, day.date.day);
    final dayName = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ][weekday.weekday - 1];
    const monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthName = monthNames[day.date.month];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text('$dayName, $monthName ${day.date.day}',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textSecondary)),
                const Spacer(),
                if (day.incomeTotal > 0) ...[
                  AmountText(
                      minor: day.incomeTotal, size: 13, isExpense: false),
                  const SizedBox(width: 8),
                ],
                AmountText(minor: day.expenseTotal, size: 13, isExpense: true),
              ],
            ),
          ),
          const Divider(height: 1),
          ...day.expenses.map((e) => _ExpenseRow(expense: e)),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  final Expense expense;
  const _ExpenseRow({required this.expense});

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
              child: const Text('Cancel')),
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
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Dismissible(
        key: ValueKey(expense.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: AppTheme.expense,
          child: const Icon(Icons.delete_outline,
              color: Colors.white, size: 22),
        ),
        confirmDismiss: (_) => _delete(context, ref),
        child: InkWell(
          onTap: () => _edit(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                CategoryChip(category: expense.category, compact: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(expense.notes ?? expense.category.label,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.textPrimary),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                Text(
                  '${expense.isIncome ? '+' : '-'}${Money.format(expense.amountMinor)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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
                        size: 13, color: AppTheme.textSecondary),
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
                        size: 13, color: AppTheme.expense),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class HistoryBody extends ConsumerWidget {
  const HistoryBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
            child: _RangeFilterChips(state: state, notifier: notifier)),
        SliverToBoxAdapter(
            child: _RangeHeader(state: state, notifier: notifier)),
        SliverToBoxAdapter(
            child: _CategoryFilter(state: state, notifier: notifier)),
        if (state.days.isEmpty)
          SliverFillRemaining(child: _HistoryEmptyState())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _DaySection(day: state.days[index]),
              childCount: state.days.length,
            ),
          ),
      ],
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48,
              color: AppTheme.textSecondary.withAlpha(100)),
          const SizedBox(height: 16),
          const Text('No transactions yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap + to add your first expense',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
