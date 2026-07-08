import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/trade.dart';

class TradeDashboardScreen extends ConsumerWidget {
  const TradeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tradeControllerProvider);
    final closed = state.closedTrades;
    final hasTrades = state.allTrades.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('P&L Summary')),
      body: !hasTrades
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart,
                      size: 48,
                      color: AppTheme.textSecondary.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No trade data yet',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _PnlHeroCard(state: state),
                const SizedBox(height: 16),
                _HeroStatsRow(state: state),
                const SizedBox(height: 16),
                _PnLDistributionChart(closed: closed),
                const SizedBox(height: 16),
                _MonthlyPnLBarChart(closed: closed),
                const SizedBox(height: 16),
                _TradeTypeBreakdown(closed: closed),
                const SizedBox(height: 16),
                _PerformanceInsights(closed: closed, allTrades: state.allTrades),
                const SizedBox(height: 16),
                _WeekdayHeatmap(closed: closed),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}

class _PnlHeroCard extends StatelessWidget {
  final dynamic state;
  const _PnlHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.totalPnl as int;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: total >= 0
              ? [
                  AppTheme.income.withAlpha(40),
                  AppTheme.cardSurface.withAlpha(200)
                ]
              : [
                  AppTheme.expense.withAlpha(40),
                  AppTheme.cardSurface.withAlpha(200)
                ],
        ),
        border: Border.all(
          color: (total >= 0 ? AppTheme.income : AppTheme.expense)
              .withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          const Text('Realized P&L',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text(
            total >= 0
                ? '+${Money.format(total)}'
                : Money.format(total),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: total >= 0 ? AppTheme.income : AppTheme.expense,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsRow extends StatelessWidget {
  final dynamic state;
  const _HeroStatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    final bestTrade = _bestTrade(state.closedTrades);
    final worstTrade = _worstTrade(state.closedTrades);
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Total P&L',
            value: state.totalPnl >= 0
                ? '+${Money.format(state.totalPnl)}'
                : Money.format(state.totalPnl),
            color: state.totalPnl >= 0 ? AppTheme.income : AppTheme.expense,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.trending_up_rounded,
            label: 'Win Rate',
            value: '${state.winRate.toStringAsFixed(1)}%',
            color: AppTheme.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.swap_vert_rounded,
            label: 'Trades',
            value: '${state.allTrades.length}',
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.arrow_upward_rounded,
            label: 'Best',
            value: bestTrade != null
                ? Money.format(bestTrade.netPnl)
                : '—',
            color: AppTheme.income,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.arrow_downward_rounded,
            label: 'Worst',
            value: worstTrade != null
                ? Money.format(worstTrade.netPnl.abs())
                : '—',
            color: AppTheme.expense,
          ),
        ),
      ],
    );
  }

  Trade? _bestTrade(List<Trade> closed) {
    if (closed.isEmpty) return null;
    Trade? best;
    for (final t in closed) {
      if (t.isProfitable && (best == null || t.netPnl > best.netPnl)) {
        best = t;
      }
    }
    return best;
  }

  Trade? _worstTrade(List<Trade> closed) {
    if (closed.isEmpty) return null;
    Trade? worst;
    for (final t in closed) {
      if (!t.isProfitable && (worst == null || t.netPnl < worst.netPnl)) {
        worst = t;
      }
    }
    return worst;
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PnLDistributionChart extends StatelessWidget {
  final List<Trade> closed;
  const _PnLDistributionChart({required this.closed});

  @override
  Widget build(BuildContext context) {
    final profits = closed.where((t) => t.isProfitable).toList();
    final losses = closed.where((t) => !t.isProfitable).toList();

    final totalProfit = profits.fold<int>(0, (s, t) => s + t.netPnl);
    final totalLoss = losses.fold<int>(0, (s, t) => s + t.netPnl).abs();

    final maxVal = max(totalProfit, totalLoss).toDouble();
    final scale = maxVal > 0 ? maxVal : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('P&L Distribution',
              style: AppTheme.sectionTitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profits',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppTheme.incomeGlass,
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: totalProfit / scale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppTheme.income,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(Money.format(totalProfit),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.income)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Losses',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppTheme.expenseGlass,
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: totalLoss / scale,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppTheme.expense,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(Money.format(totalLoss),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.expense)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyPnLBarChart extends StatelessWidget {
  final List<Trade> closed;
  const _MonthlyPnLBarChart({required this.closed});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyData = <String, int>{};

    for (int i = 5; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      monthlyData[key] = 0;
    }

    for (final t in closed) {
      final exit = t.exitDate;
      if (exit == null) continue;
      final key = '${exit.year}-${exit.month.toString().padLeft(2, '0')}';
      if (monthlyData.containsKey(key)) {
        monthlyData[key] = (monthlyData[key] ?? 0) + t.netPnl;
      }
    }

    final entries = monthlyData.entries.toList();
    final allPositive = entries.every((e) => e.value >= 0);
    final allNegative = entries.every((e) => e.value <= 0);
    final minVal = entries.fold<int>(0, (m, e) => e.value < m ? e.value : m);
    final maxVal = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final maxAbs = max(maxVal.abs(), minVal.abs()).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly P&L (Last 6)',
              style: AppTheme.sectionTitle),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: allNegative ? 0 : maxAbs * 1.2,
                minY: allPositive ? 0 : -maxAbs * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${entries[groupIndex].key}\n${Money.format(rod.toY.round())}',
                        const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        final parts = entries[idx].key.split('-');
                        final monthNames = [
                          '', 'J', 'F', 'M', 'A', 'M', 'J',
                          'J', 'A', 'S', 'O', 'N', 'D'
                        ];
                        final month = int.tryParse(parts[1]) ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(monthNames[month],
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxAbs > 0 ? maxAbs / 4 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 0.5,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((e) {
                  final val = e.value.value;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: val.toDouble(),
                        color: val >= 0 ? AppTheme.income : AppTheme.expense,
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                            bottom: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeTypeBreakdown extends StatelessWidget {
  final List<Trade> closed;
  const _TradeTypeBreakdown({required this.closed});

  @override
  Widget build(BuildContext context) {
    final breakdown = <TradeType, List<Trade>>{};
    for (final t in closed) {
      breakdown.putIfAbsent(t.tradeType, () => []);
      breakdown[t.tradeType]!.add(t);
    }

    final types = [
      TradeType.equity,
      TradeType.futures,
      TradeType.options,
      TradeType.crypto,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trade Type Breakdown',
              style: AppTheme.sectionTitle),
          const SizedBox(height: 14),
          ...types.map((type) {
            final trades = breakdown[type] ?? [];
            final count = trades.length;
            final pnl = trades.fold<int>(0, (s, t) => s + t.netPnl);
            final icon = _typeIcon(type);
            final color = _typeColor(type);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textPrimary)),
                        Text('$count trade${count == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Text(
                    pnl >= 0
                        ? '+${Money.format(pnl)}'
                        : Money.format(pnl),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: pnl >= 0 ? AppTheme.income : AppTheme.expense,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _typeIcon(TradeType type) {
    switch (type) {
      case TradeType.equity:
        return Icons.business_center_rounded;
      case TradeType.futures:
        return Icons.show_chart_rounded;
      case TradeType.options:
        return Icons.schedule_rounded;
      case TradeType.crypto:
        return Icons.currency_bitcoin_rounded;
    }
  }

  Color _typeColor(TradeType type) {
    switch (type) {
      case TradeType.equity:
        return AppTheme.primary;
      case TradeType.futures:
        return AppTheme.accent;
      case TradeType.options:
        return AppTheme.warning;
      case TradeType.crypto:
        return const Color(0xFFF7931A);
    }
  }
}

class _PerformanceInsights extends StatelessWidget {
  final List<Trade> closed;
  final List<Trade> allTrades;
  const _PerformanceInsights(
      {required this.closed, required this.allTrades});

  @override
  Widget build(BuildContext context) {
    final bestMonth = _bestMonth(closed);
    final worstMonth = _worstMonth(closed);
    final mostTraded = _mostTradedInstrument(closed);
    final avgHolding = _avgHoldingPeriod(closed);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Insights',
              style: AppTheme.sectionTitle),
          const SizedBox(height: 14),
          _InsightRow(
            icon: Icons.calendar_month_rounded,
            label: 'Best Month',
            value: bestMonth,
            color: AppTheme.income,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.calendar_month_rounded,
            label: 'Worst Month',
            value: worstMonth,
            color: AppTheme.expense,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.repeat_rounded,
            label: 'Most Traded',
            value: mostTraded,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.timer_rounded,
            label: 'Avg Holding',
            value: avgHolding,
            color: AppTheme.accent,
          ),
        ],
      ),
    );
  }

  String _bestMonth(List<Trade> closed) {
    final months = <String, int>{};
    for (final t in closed) {
      final d = t.exitDate;
      if (d == null) continue;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      months[key] = (months[key] ?? 0) + t.netPnl;
    }
    if (months.isEmpty) return '—';
    final best = months.entries.reduce(
        (a, b) => a.value >= b.value ? a : b);
    final parts = best.key.split('-');
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${monthNames[m]} ${parts[0]} (+${Money.format(best.value)})';
  }

  String _worstMonth(List<Trade> closed) {
    final months = <String, int>{};
    for (final t in closed) {
      final d = t.exitDate;
      if (d == null) continue;
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      months[key] = (months[key] ?? 0) + t.netPnl;
    }
    if (months.isEmpty) return '—';
    final worst = months.entries.reduce(
        (a, b) => a.value <= b.value ? a : b);
    final parts = worst.key.split('-');
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = int.tryParse(parts[1]) ?? 0;
    return '${monthNames[m]} ${parts[0]} (${Money.format(worst.value)})';
  }

  String _mostTradedInstrument(List<Trade> closed) {
    if (closed.isEmpty) return '—';
    final counts = <String, int>{};
    for (final t in closed) {
      counts[t.instrumentName] =
          (counts[t.instrumentName] ?? 0) + 1;
    }
    return counts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String _avgHoldingPeriod(List<Trade> closed) {
    final withDuration = closed.where((t) => t.exitDate != null).toList();
    if (withDuration.isEmpty) return '—';
    double totalDays = 0;
    for (final t in withDuration) {
      totalDays += t.exitDate!
          .difference(t.entryDate)
          .inHours /
          24.0;
    }
    final avg = totalDays / withDuration.length;
    if (avg < 1) {
      return '${(avg * 24).round()}h';
    } else if (avg < 30) {
      return '${avg.toStringAsFixed(1)} days';
    } else {
      return '${(avg / 30).toStringAsFixed(1)} mo';
    }
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _WeekdayHeatmap extends StatelessWidget {
  final List<Trade> closed;
  const _WeekdayHeatmap({required this.closed});

  @override
  Widget build(BuildContext context) {
    final dayCounts = List.filled(7, 0);
    for (final t in closed) {
      final d = t.exitDate ?? t.entryDate;
      dayCounts[d.weekday % 7]++;
    }
    final maxCount = dayCounts.reduce(max).toDouble();

    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trade Frequency',
              style: AppTheme.sectionTitle),
          const SizedBox(height: 14),
          ...List.generate(7, (i) {
            final count = dayCounts[i];
            final fraction = maxCount > 0 ? count / maxCount : 0.0;
            final alpha = (20 + (fraction * 180)).round().clamp(20, 200);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(dayLabels[i],
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppTheme.primary.withAlpha(alpha),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: fraction,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: AppTheme.primary.withAlpha(200),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 28,
                    child: Text('$count',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                        textAlign: TextAlign.right),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
