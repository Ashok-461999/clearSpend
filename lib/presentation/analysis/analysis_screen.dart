import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/history/history_controller.dart';
import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/date_range.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/expense.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analysisControllerProvider);
    final notifier = ref.read(analysisControllerProvider.notifier);
    final allExpenses =
        state.days.expand((d) => d.expenses).where((e) => !e.isIncome).toList();

    final total = state.totalExpense;
    final count = allExpenses.length;

    final catTotals = <Category, int>{};
    int wasted = 0;
    int essential = 0;
    for (final e in allExpenses) {
      catTotals.update(e.category, (v) => v + e.amountMinor, ifAbsent: () => e.amountMinor);
      if (e.category.isEssential) {
        essential += e.amountMinor;
      } else {
        wasted += e.amountMinor;
      }
    }
    final sortedCats = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final wastePct = total > 0 ? (wasted / total * 100) : 0.0;
    final daysInRange = state.days.length;
    final dailyAvg = daysInRange > 0 ? total ~/ daysInRange : 0;

    final topExpenses = allExpenses.toList()
      ..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));

    final sortedDays = List<DayGroup>.from(state.days)
      ..sort((a, b) => a.date.compareTo(b.date));

    final weekdayTotals = List.filled(7, 0);
    final weekdayCounts = List.filled(7, 0);
    for (final d in sortedDays) {
      final wd = d.date.weekday - 1;
      weekdayTotals[wd] += d.total;
      weekdayCounts[wd]++;
    }
    final weekdayAvg = weekdayTotals.asMap().entries
        .map((e) => weekdayCounts[e.key] > 0 ? e.value ~/ weekdayCounts[e.key] : 0)
        .toList();
    final maxWeekday = weekdayAvg.isEmpty ? 0 : weekdayAvg.reduce((a, b) => a > b ? a : b);

    final slope = _computeTrend(sortedDays);
    final smaWindow =
        sortedDays.length >= 14 ? 7 : (sortedDays.length >= 7 ? 3 : 0);
    final sma = smaWindow > 0 ? _computeSMA(sortedDays, smaWindow) : <double?>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analysis'),
        actions: [_buildHealthBadge(wastePct)],
      ),
      body: allExpenses.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _RangeFilterRow(state: state, notifier: notifier),
                const SizedBox(height: 16),
                _MetricRow(total: total, count: count, dailyAvg: dailyAvg),
                const SizedBox(height: 20),
                _WasteGauge(wastePct: wastePct, wasted: wasted, essential: essential),
                const SizedBox(height: 20),
                _SpendingTrendChart(days: sortedDays, sma: sma, slope: slope),
                const SizedBox(height: 20),
                _WeekdayChart(weekdayAvg: weekdayAvg, maxValue: maxWeekday),
                const SizedBox(height: 20),
                _CategoryPieChart(catTotals: catTotals, total: total),
                const SizedBox(height: 20),
                _InsightsCard(
                    total: total,
                    count: count,
                    dailyAvg: dailyAvg,
                    slope: slope,
                    sortedCats: sortedCats,
                    weekdayAvg: weekdayAvg,
                    topExpenses: topExpenses,
                    wastePct: wastePct),
                const SizedBox(height: 20),
                if (sortedCats.isNotEmpty) ...[
                  const Text('Category Analysis', style: AppTheme.sectionTitle),
                  const SizedBox(height: 12),
                  ...sortedCats.map((e) => _CategoryAnalysisTile(
                      category: e.key, amount: e.value, total: total)),
                  const SizedBox(height: 20),
                ],
                if (topExpenses.isNotEmpty) ...[
                  const Text('Top Expenses', style: AppTheme.sectionTitle),
                  const SizedBox(height: 8),
                  ...topExpenses.take(5).map((e) => _TopExpenseRow(expense: e)),
                  const SizedBox(height: 20),
                ],
                if (state.days.isNotEmpty) ...[
                  const Text('Daily Breakdown', style: AppTheme.sectionTitle),
                  const SizedBox(height: 8),
                  ...state.days.map((d) => _DayBreakdownCard(day: d)),
                ],
              ],
            ),
    );
  }

  Widget _buildHealthBadge(double wastePct) {
    final isGood = wastePct <= 50;
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isGood ? AppTheme.incomeGlass : AppTheme.expenseGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isGood ? AppTheme.income.withAlpha(60) : AppTheme.expense.withAlpha(60),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: isGood ? AppTheme.income : AppTheme.expense,
          ),
          const SizedBox(width: 4),
          Text(
            isGood ? 'Good control' : 'High waste',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isGood ? AppTheme.income : AppTheme.expense),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.analytics_outlined,
                size: 56, color: AppTheme.textSecondary.withAlpha(100)),
          ),
          const SizedBox(height: 20),
          const Text('No data to analyse yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Add some expenses to see insights',
              style: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(150), fontSize: 14)),
        ],
      ),
    );
  }

  static double _computeTrend(List<DayGroup> days) {
    if (days.length < 2) return 0;
    final n = days.length;
    final x = List.generate(n, (i) => i.toDouble());
    final y = days.map((d) => d.total.toDouble()).toList();
    final sumX = x.fold(0.0, (a, b) => a + b);
    final sumY = y.fold(0.0, (a, b) => a + b);
    final sumXY = x.asMap().entries.map((e) => e.value * y[e.key]).fold(0.0, (a, b) => a + b);
    final sumX2 = x.fold(0.0, (a, b) => a + b * b);
    if ((n * sumX2 - sumX * sumX) == 0) return 0;
    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }

  static List<double?> _computeSMA(List<DayGroup> days, int window) {
    final values = days.map((d) => d.total).toList();
    final result = List<double?>.filled(values.length, null);
    for (int i = window - 1; i < values.length; i++) {
      double sum = 0;
      for (int j = 0; j < window; j++) sum += values[i - j];
      result[i] = sum / window;
    }
    return result;
  }
}

class _RangeFilterRow extends StatelessWidget {
  final HistoryState state;
  final HistoryController notifier;
  const _RangeFilterRow({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final type in DateRangeType.values)
              Padding(
                padding: const EdgeInsets.only(right: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            fontWeight: state.rangeType == type
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: state.rangeType == type
                                ? AppTheme.primary
                                : AppTheme.textSecondary)),
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
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      notifier.setCustomRange(picked.start, picked.end.add(const Duration(days: 1)));
    }
  }
}

class _MetricRow extends StatelessWidget {
  final int total;
  final int count;
  final int dailyAvg;
  const _MetricRow({required this.total, required this.count, required this.dailyAvg});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _MetricCard(
                label: 'Total Spent',
                value: Money.format(total),
                icon: Icons.account_balance_wallet_rounded,
                color: AppTheme.expense)),
        const SizedBox(width: 10),
        Expanded(
            child: _MetricCard(
                label: 'Transactions',
                value: '$count',
                icon: Icons.receipt_long_rounded,
                color: AppTheme.warning)),
        const SizedBox(width: 10),
        Expanded(
            child: _MetricCard(
                label: 'Daily Avg',
                value: Money.format(dailyAvg),
                icon: Icons.trending_up_rounded,
                color: AppTheme.accent)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard(
      {required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, anim, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - anim)),
          child: Opacity(
            opacity: anim,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface.withAlpha(200),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 16, color: color),
                  ),
                  const SizedBox(height: 10),
                  Text(value,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: color)),
                  const SizedBox(height: 2),
                  Text(label,
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WasteGauge extends StatelessWidget {
  final double wastePct;
  final int wasted;
  final int essential;
  const _WasteGauge(
      {required this.wastePct, required this.wasted, required this.essential});

  @override
  Widget build(BuildContext context) {
    final wasteRounded = wastePct.round();
    final essentialPct = 100 - wasteRounded;

    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.expenseGlass,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.money_off_csred_outlined,
                    color: AppTheme.expense, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Essential vs Wasted',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary)),
                    Text('Need vs Want breakdown',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Money.format(wasted),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppTheme.expense)),
                  Text('$wasteRounded% wasted',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, anim, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 14,
                  child: Row(
                    children: [
                      Expanded(
                        flex: (essentialPct * anim).round().clamp(1, 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.income, Color(0xFF16A34A)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: essentialPct > 15
                              ? const Text('ESSENTIAL',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5))
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: (wasteRounded * anim).round().clamp(1, 100),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.expense, Color(0xFFDC2626)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: wasteRounded > 15
                              ? const Text('WASTED',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5))
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
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
          if (wastePct > 50) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.expenseGlass,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline,
                      size: 16, color: AppTheme.expense),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                        'More than half your spending is on non-essentials. Try cutting back to save more.',
                        style: const TextStyle(
                            fontSize: 11, color: AppTheme.expense)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  const _LegendDot({required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(width: 6),
        Text(amount,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _SpendingTrendChart extends StatelessWidget {
  final List<DayGroup> days;
  final List<double?> sma;
  final double slope;
  const _SpendingTrendChart(
      {required this.days, required this.sma, required this.slope});

  @override
  Widget build(BuildContext context) {
    if (days.length < 2) return const SizedBox.shrink();

    final totalValues = days.map((d) => d.total).toList();
    final maxTotal = totalValues.reduce(max);
    final safeMax = maxTotal > 0 ? maxTotal * 1.25 : 1000.0;

    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      spots.add(FlSpot(i.toDouble(), days[i].total.toDouble()));
    }

    final smaSpots = <FlSpot>[];
    for (int i = 0; i < sma.length; i++) {
      if (sma[i] != null) smaSpots.add(FlSpot(i.toDouble(), sma[i]!));
    }

    final firstY = days[0].total.toDouble();
    final lastY = days.last.total.toDouble() + slope * (days.length - 1);
    final regSpots = <FlSpot>[
      FlSpot(0, firstY),
      FlSpot((days.length - 1).toDouble(), lastY),
    ];

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.primaryGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Spending Trend',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              if (slope.abs() > 0.5)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (slope > 0 ? AppTheme.expense : AppTheme.income)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        slope > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: slope > 0 ? AppTheme.expense : AppTheme.income,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${slope > 0 ? '+' : ''}${(slope / 100).toStringAsFixed(1)}/d',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                slope > 0 ? AppTheme.expense : AppTheme.income),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: AppTheme.border, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('₹${(value / 100).round()}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval:
                          max(1, (days.length / 6).round()).toDouble(),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final d = days[idx].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${d.day} ${months[d.month]}',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: safeMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: AppTheme.primary,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 31,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: AppTheme.cardSurface,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primary.withAlpha(25),
                    ),
                  ),
                  if (smaSpots.length >= 2)
                    LineChartBarData(
                      spots: smaSpots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      color: AppTheme.warning,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                  if (regSpots.length >= 2)
                    LineChartBarData(
                      spots: regSpots,
                      isCurved: false,
                      color: (slope >= 0 ? AppTheme.expense : AppTheme.income)
                          .withAlpha(120),
                      barWidth: 1.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      dashArray: [6, 4],
                    ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final dateStr = idx >= 0 && idx < days.length
                            ? '${days[idx].date.day}/${days[idx].date.month}'
                            : '';
                        return LineTooltipItem(
                          '$dateStr\n${Money.format(spot.y.round())}',
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _TrendLegend(color: AppTheme.primary, label: 'Daily spend'),
              const SizedBox(width: 16),
              if (smaSpots.length >= 2)
                _TrendLegend(
                    color: AppTheme.warning, label: '${sma.length}-day avg'),
              if (regSpots.length >= 2) ...[
                const SizedBox(width: 16),
                _TrendLegend(
                    color: (slope >= 0 ? AppTheme.expense : AppTheme.income)
                        .withAlpha(120),
                    label: 'Trend line',
                    dashed: true),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _TrendLegend(
      {required this.color, required this.label, this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: dashed ? 1 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _WeekdayChart extends StatelessWidget {
  final List<int> weekdayAvg;
  final int maxValue;
  const _WeekdayChart({required this.weekdayAvg, required this.maxValue});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    if (weekdayAvg.every((v) => v == 0)) return const SizedBox.shrink();
    final safeMax = maxValue > 0 ? maxValue * 1.3 : 1000.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.warningGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calendar_view_week,
                    color: AppTheme.warning, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Spending by Weekday',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Text('Avg per day',
                  style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: safeMax,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_dayLabels[groupIndex]}\n${Money.format(rod.toY.round())}',
                        const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('₹${(value / 100).round()}',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= 7) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(_dayLabels[idx],
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: weekdayAvg[idx] == maxValue &&
                                          maxValue > 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: idx >= 5
                                      ? AppTheme.expense
                                      : AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: safeMax / 4,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: AppTheme.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  final isMax = maxValue > 0 && weekdayAvg[i] == maxValue;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: weekdayAvg[i].toDouble(),
                        color: i >= 5
                            ? (isMax
                                ? AppTheme.expense
                                : AppTheme.expense.withAlpha(150))
                            : (isMax
                                ? AppTheme.primary
                                : AppTheme.primary.withAlpha(150)),
                        width: 18,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final Map<Category, int> catTotals;
  final int total;
  const _CategoryPieChart({required this.catTotals, required this.total});

  @override
  Widget build(BuildContext context) {
    if (catTotals.isEmpty) return const SizedBox.shrink();

    final sorted = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.warningGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.pie_chart,
                    color: AppTheme.warning, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Category Distribution',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 190,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 38,
                      sections: sorted.map((entry) {
                        final pct =
                            total > 0 ? (entry.value / total * 100) : 0.0;
                        return PieChartSectionData(
                          color: entry.key.color,
                          value: pct,
                          title: pct >= 5 ? '${pct.round()}%' : '',
                          radius: 48,
                          titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: sorted.take(6).map((entry) {
                    final pct =
                        total > 0 ? (entry.value / total * 100) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: entry.key.color,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(entry.key.label,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('${pct.round()}%',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  final int total;
  final int count;
  final int dailyAvg;
  final double slope;
  final List<MapEntry<Category, int>> sortedCats;
  final List<int> weekdayAvg;
  final List<Expense> topExpenses;
  final double wastePct;

  const _InsightsCard({
    required this.total,
    required this.count,
    required this.dailyAvg,
    required this.slope,
    required this.sortedCats,
    required this.weekdayAvg,
    required this.topExpenses,
    required this.wastePct,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final maxWday = weekdayAvg.isEmpty
        ? -1
        : weekdayAvg.indexOf(weekdayAvg.reduce(max));
    final topCat = sortedCats.isNotEmpty ? sortedCats.first.key : null;
    final topAmt = sortedCats.isNotEmpty ? sortedCats.first.value : 0;
    final topPct = total > 0 && topAmt > 0 ? (topAmt / total * 100).round() : 0;
    final biggestExpense = topExpenses.isNotEmpty ? topExpenses.first : null;
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final insights = <_InsightItem>[
      if (dailyAvg > 0)
        _InsightItem(
          icon: Icons.trending_up,
          iconColor: slope > 0 ? AppTheme.expense : AppTheme.income,
          text:
              'You spend ${Money.format(dailyAvg)} per day${slope.abs() > 0.5 ? ', ${slope > 0 ? "up" : "down"} ₹${(slope.abs() / 100).toStringAsFixed(1)}/day' : ''}',
        ),
      if (topCat != null)
        _InsightItem(
          icon: topCat.icon,
          iconColor: topCat.color,
          text: '$topCat is your biggest category at $topPct% of spending',
        ),
      if (maxWday >= 0 && weekdayAvg[maxWday] > 0)
        _InsightItem(
          icon: Icons.calendar_today,
          iconColor: maxWday >= 5 ? AppTheme.expense : AppTheme.primary,
          text: '${dayNames[maxWday]} is your highest spending day',
        ),
      if (biggestExpense != null)
        _InsightItem(
          icon: Icons.local_fire_department,
          iconColor: AppTheme.warning,
          text:
              'Biggest expense: ${Money.format(biggestExpense.amountMinor)} on ${biggestExpense.notes ?? biggestExpense.category.label}',
        ),
      if (count > 0)
        _InsightItem(
          icon: Icons.receipt_long,
          iconColor: AppTheme.warning,
          text: '$count transactions in this period',
        ),
      if (wastePct > 50)
        _InsightItem(
          icon: Icons.warning_amber_rounded,
          iconColor: AppTheme.expense,
          text:
              '${wastePct.round()}% is wasted on non-essentials — try to cut back',
        ),
    ];

    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.accentGlass,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: AppTheme.accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Key Insights',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: i.iconColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(i.icon, size: 14, color: i.iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(i.text,
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.3)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InsightItem {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _InsightItem(
      {required this.icon, required this.iconColor, required this.text});
}

class _CategoryAnalysisTile extends StatelessWidget {
  final Category category;
  final int amount;
  final int total;
  const _CategoryAnalysisTile(
      {required this.category, required this.amount, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (amount / total * 100) : 0.0;
    final fraction = pct / 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: category.color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(category.label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppTheme.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.isEssential
                            ? AppTheme.incomeGlass
                            : AppTheme.expenseGlass,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                          category.isEssential ? 'Need' : 'Want',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: category.isEssential
                                  ? AppTheme.income
                                  : AppTheme.expense)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: category.color.withAlpha(20),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(category.color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Money.format(amount),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
              Text('${pct.round()}%',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopExpenseRow extends StatelessWidget {
  final Expense expense;
  const _TopExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: expense.category.color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(expense.category.icon,
                color: expense.category.color, size: 18),
          ),
          const SizedBox(width: 12),
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
                Text(_formatDate(expense.localDate),
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(Money.format(expense.amountMinor),
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.expense)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DayBreakdownCard extends StatelessWidget {
  final DayGroup day;
  const _DayBreakdownCard({required this.day});

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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
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
                Text(Money.format(day.total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.expense)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...day.expenses.map((e) => _MiniExpenseRow(expense: e)),
        ],
      ),
    );
  }
}

class _MiniExpenseRow extends StatelessWidget {
  final Expense expense;
  const _MiniExpenseRow({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: expense.category.color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(expense.category.icon,
                color: expense.category.color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(expense.notes ?? expense.category.label,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          Text(Money.format(expense.amountMinor),
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppTheme.expense)),
        ],
      ),
    );
  }
}
