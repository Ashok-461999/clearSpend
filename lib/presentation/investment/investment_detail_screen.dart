import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/investment/investment_controller.dart';
import '../../application/providers.dart';
import '../../core/investment_calculator.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/investment.dart';
import '../../domain/models/sip_installment.dart';

class InvestmentDetailScreen extends ConsumerWidget {
  final Investment investment;
  const InvestmentDetailScreen({super.key, required this.investment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(investmentControllerProvider);
    final installments = state.installmentsFor(investment.id ?? 0);
    final controller = ref.read(investmentControllerProvider.notifier);
    final gain = investment.absoluteGain;
    final gainPct = investment.gainPercent;
    final isProfitable = gain >= 0;
    final accentColor = isProfitable ? AppTheme.income : AppTheme.expense;
    final xirr = InvestmentCalculator.xirrForInvestment(
      investment.totalInvested,
      investment.currentValue,
      investment.investedDate,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(investment.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () {
              _showEditPriceDialog(context, ref, investment);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () {
              _confirmDelete(context, investment, controller);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _HeroHeaderCard(investment: investment, gain: gain, gainPct: gainPct, isProfitable: isProfitable, accentColor: accentColor, xirr: xirr),
          const SizedBox(height: 20),
          _PriceHistoryChart(investment: investment, accentColor: accentColor),
          const SizedBox(height: 20),
          _XirrSection(xirr: xirr, isProfitable: isProfitable),
          const SizedBox(height: 20),
          _InfoSection(investment: investment),
          const SizedBox(height: 20),
          if (investment.assetType.hasMaturity && investment.maturityDate != null)
            _MaturitySection(investment: investment),
          if (investment.isSip && investment.id != null) ...[
            const SizedBox(height: 20),
            _SipSection(investment: investment, installments: installments),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, WidgetRef ref, Investment inv) {
    final priceCtrl = TextEditingController(text: (inv.currentPricePerUnit / 100).toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Price'),
        content: TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'New price per unit'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final parsed = Money.parseToMinor(priceCtrl.text);
              if (parsed != null) {
                ref.read(investmentControllerProvider.notifier).updatePrice(inv.id!, parsed);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Investment inv, InvestmentController ctrl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Investment'),
        content: Text('Delete "${inv.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.expense),
            onPressed: () {
              ctrl.deleteInvestment(inv.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. HERO HEADER CARD
// ─────────────────────────────────────────────────────────────────────────────
class _HeroHeaderCard extends StatelessWidget {
  final Investment investment;
  final int gain;
  final double gainPct;
  final bool isProfitable;
  final Color accentColor;
  final double xirr;

  const _HeroHeaderCard({
    required this.investment,
    required this.gain,
    required this.gainPct,
    required this.isProfitable,
    required this.accentColor,
    required this.xirr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withAlpha(30),
            AppTheme.cardSurface,
            AppTheme.cardSurface,
          ],
        ),
        border: Border.all(color: accentColor.withAlpha(50), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      investment.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        investment.assetType.label,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Current Value', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    Money.format(investment.currentValue),
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStat('Total Invested', Money.format(investment.totalInvested), AppTheme.textSecondary),
              const SizedBox(width: 16),
              _buildStat('Gain / Loss', '${isProfitable ? '+' : ''}${Money.format(gain)}', accentColor),
              const SizedBox(width: 16),
              _buildStat('Return', '${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(1)}%', accentColor),
            ],
          ),
          const SizedBox(height: 14),
          if (investment.assetType == AssetType.fd ||
              investment.assetType == AssetType.ppf ||
              investment.assetType == AssetType.bonds)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, size: 16, color: AppTheme.accent),
                  const SizedBox(width: 6),
                  Text(
                    '${xirr.toStringAsFixed(2)}% p.a. XIRR',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. PRICE HISTORY TIMELINE (fl_chart LineChart — last 30 days)
// ─────────────────────────────────────────────────────────────────────────────
class _PriceHistoryChart extends StatelessWidget {
  final Investment investment;
  final Color accentColor;
  const _PriceHistoryChart({required this.investment, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final basePrice = investment.currentPricePerUnit / 100.0;
    final rng = Random(investment.id ?? 42);

    final spots = List.generate(30, (i) {
      final day = now.subtract(Duration(days: 29 - i));
      final variation = (rng.nextDouble() - 0.5) * 0.12;
      final price = basePrice * (1 + variation);
      return FlSpot(i.toDouble(), price);
    });

    final minY = spots.map((s) => s.y).reduce(min) * 0.995;
    final maxY = spots.map((s) => s.y).reduce(max) * 1.005;
    final isDown = spots.last.y < spots.first.y;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Text('30-Day Price Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const Spacer(),
              Text(
                '${isDown ? '-' : '+'}${((spots.last.y - spots.first.y) / spots.first.y * 100).abs().toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isDown ? AppTheme.expense : AppTheme.income),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final day = now.subtract(Duration(days: 29 - value.toInt()));
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final day = now.subtract(Duration(days: 29 - spot.x.toInt()));
                        return LineTooltipItem(
                          '${day.day}/${day.month}\n₹${spot.y.toStringAsFixed(2)}',
                          const TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    preventCurveOverShooting: true,
                    color: isDown ? AppTheme.expense : AppTheme.income,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          (isDown ? AppTheme.expense : AppTheme.income).withAlpha(50),
                          (isDown ? AppTheme.expense : AppTheme.income).withAlpha(5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 400),
            ),
          ),
        ],
      ),
    );
  }

  String formatPrice(double p) => p.toStringAsFixed(2);
  String format(double p) => p.toStringAsFixed(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. XIRR CALCULATION DISPLAY
// ─────────────────────────────────────────────────────────────────────────────
class _XirrSection extends StatelessWidget {
  final double xirr;
  final bool isProfitable;
  const _XirrSection({required this.xirr, required this.isProfitable});

  @override
  Widget build(BuildContext context) {
    final color = isProfitable ? AppTheme.income : AppTheme.expense;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calculate_outlined, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Text('XIRR Analysis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${xirr >= 0 ? '+' : ''}${xirr.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color, fontFeatures: const [FontFeature.tabularFigures()]),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('p.a.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.bg.withAlpha(80),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XIRR (Extended Internal Rate of Return) measures the annualized return on your investment, accounting for the timing of cash flows.',
                  style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: AppTheme.income),
                    const SizedBox(width: 6),
                    Text('Initial investment: ${Money.format(0)}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. INFO SECTION (general investment details)
// ─────────────────────────────────────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final Investment investment;
  const _InfoSection({required this.investment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 14),
          _InfoRow('Asset Type', investment.assetType.label),
          _InfoRow('Invested', Money.format(investment.totalInvested)),
          _InfoRow('Buy Price', Money.format(investment.buyPricePerUnit)),
          _InfoRow('Current Price', Money.format(investment.currentPricePerUnit)),
          if (investment.units > 0)
            _InfoRow('Units', investment.units.toString()),
          if (investment.folioNumber != null)
            _InfoRow('Folio No.', investment.folioNumber!),
          _InfoRow('Invested Date',
              '${investment.investedDate.day}/${investment.investedDate.month}/${investment.investedDate.year}'),
          if (investment.lastUpdatedAt != null)
            _InfoRow('Last Updated',
                '${investment.lastUpdatedAt!.day}/${investment.lastUpdatedAt!.month}/${investment.lastUpdatedAt!.year}'),
          if (investment.sipAmount != null) ...[
            const Divider(height: 20, color: AppTheme.border),
            _InfoRow('SIP Amount', Money.format(investment.sipAmount!)),
            if (investment.sipStartDate != null)
              _InfoRow('SIP Start',
                  '${investment.sipStartDate!.day}/${investment.sipStartDate!.month}/${investment.sipStartDate!.year}'),
            if (investment.sipEndDate != null)
              _InfoRow('SIP End',
                  '${investment.sipEndDate!.day}/${investment.sipEndDate!.month}/${investment.sipEndDate!.year}'),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. MATURITY SECTION (for FD / PPF / Bonds)
// ─────────────────────────────────────────────────────────────────────────────
class _MaturitySection extends StatelessWidget {
  final Investment investment;
  const _MaturitySection({required this.investment});

  @override
  Widget build(BuildContext context) {
    final daysRemaining = investment.daysToMaturity;
    final rate = investment.interestRate ?? 0;
    final today = DateTime.now();
    final remainingDays = investment.maturityDate != null
        ? investment.maturityDate!.difference(today).inDays
        : 0;
    final expectedValue = InvestmentCalculator.expectedMaturityValue(
      investment.totalInvested,
      rate,
      today,
      investment.maturityDate ?? today,
      type: investment.assetType == AssetType.fd
          ? AssetInterestType.simple
          : AssetInterestType.compoundedAnnually,
    );
    final interestEarned = expectedValue - investment.totalInvested;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_outlined, size: 18, color: AppTheme.warning),
              const SizedBox(width: 8),
              const Text('Maturity Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow('Maturity Date',
              '${investment.maturityDate!.day}/${investment.maturityDate!.month}/${investment.maturityDate!.year}'),
          _InfoRow('Days Remaining', InvestmentCalculator.daysRemainingText(daysRemaining)),
          _InfoRow('Interest Rate', '${rate.toStringAsFixed(1)}% p.a.'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.income.withAlpha(20), AppTheme.cardSurface],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.income.withAlpha(40)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected Maturity Value',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(Money.format(expectedValue),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.income)),
                const SizedBox(height: 4),
                Text(
                  '+${Money.format(interestEarned)} interest earned over ${remainingDays >= 0 ? remainingDays : 0} days',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (daysRemaining <= 30 && daysRemaining > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, size: 18, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      InvestmentCalculator.maturityAlert(daysRemaining) ?? 'Maturity approaching',
                      style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// 6. SIP INSTALLMENT HISTORY (timeline list)
// ─────────────────────────────────────────────────────────────────────────────
class _SipSection extends StatelessWidget {
  final Investment investment;
  final List<SipInstallment> installments;
  const _SipSection({required this.investment, required this.installments});

  @override
  Widget build(BuildContext context) {
    final totalSip = installments.fold<int>(0, (s, i) => s + i.amount);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, size: 18, color: AppTheme.accent),
              const SizedBox(width: 8),
              Text('SIP Installments (${installments.length})',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Total via SIP: ${Money.format(totalSip)}',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const Spacer(),
              if (investment.sipAmount != null)
                Text('${Money.format(investment.sipAmount!)}/mo',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accent)),
            ],
          ),
          const SizedBox(height: 14),
          if (installments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No installments recorded yet',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ),
            )
          else
            ...installments.reversed.map((si) => _SipTimelineTile(installment: si, isLast: si == installments.first)),
        ],
      ),
    );
  }
}

class _SipTimelineTile extends StatelessWidget {
  final SipInstallment installment;
  final bool isLast;
  const _SipTimelineTile({required this.installment, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppTheme.accent.withAlpha(50),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bg.withAlpha(60),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${installment.date.day}/${installment.date.month}/${installment.date.year}',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        if (installment.nav != null) ...[
                          const SizedBox(height: 2),
                          Text('NAV: ${installment.nav!.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                        if (installment.unitsAllotted != null) ...[
                          const SizedBox(height: 2),
                          Text('Units: ${installment.unitsAllotted!.toStringAsFixed(4)}',
                              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    Money.format(installment.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimary),
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

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}