import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/investment/investment_controller.dart';
import '../../application/providers.dart';
import '../../core/investment_calculator.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/investment.dart';
import 'investment_detail_screen.dart';
import 'portfolio_form_screen.dart';
import 'price_update_screen.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(investmentControllerProvider);
    final investments = state.allInvestments;
    final includeInNetWorth = ref.watch(includeInvestmentsInNetWorthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          if (investments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.trending_up),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PriceUpdateScreen()),
              ),
              tooltip: 'Update Prices',
            ),
        ],
      ),
      body: investments.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_balance,
                      size: 48,
                      color: AppTheme.textSecondary.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No investments yet',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                _PortfolioHeroCard(state: state),
                const SizedBox(height: 12),
                _NetWorthToggle(
                  value: includeInNetWorth,
                  onChanged: (v) {
                    ref
                        .read(sharedPreferencesProvider)
                        .setBool('include_investments_in_net_worth', v);
                    ref
                        .read(includeInvestmentsInNetWorthProvider.notifier)
                        .state = v;
                  },
                ),
                if (state.nearingMaturity.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...state.nearingMaturity.map((inv) =>
                      _MaturityAlertCard(investment: inv)),
                ],
                const SizedBox(height: 16),
                if (state.assetAllocation.length >= 2)
                  _AllocationPieChart(allocation: state.assetAllocation),
                if (state.assetAllocation.length >= 2)
                  const SizedBox(height: 16),
                const Text('HOLDINGS',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                ...state.groupedByType.entries.map((entry) =>
                    _AssetTypeGroup(type: entry.key, items: entry.value, ref: ref)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PortfolioFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NetWorthToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _NetWorthToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet_rounded,
              size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Include in Net Worth',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _MaturityAlertCard extends StatelessWidget {
  final Investment investment;
  const _MaturityAlertCard({required this.investment});

  @override
  Widget build(BuildContext context) {
    final days = investment.daysToMaturity;
    final alert = InvestmentCalculator.maturityAlert(days);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.warning.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active,
              size: 20, color: AppTheme.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(investment.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                Text(
                  '${investment.assetType.label} - ${alert ?? "${days} days remaining"}',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationPieChart extends StatelessWidget {
  final Map<String, double> allocation;
  const _AllocationPieChart({required this.allocation});

  static const _colors = [
    AppTheme.primary,
    AppTheme.accent,
    AppTheme.warning,
    AppTheme.income,
    AppTheme.expense,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = allocation.entries.toList();
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
          const Text('Asset Allocation',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: entries.asMap().entries.map((e) {
                        return PieChartSectionData(
                          color: _colors[e.key % _colors.length],
                          value: e.value.value,
                          title: '${e.value.value.toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                          radius: 50,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: _colors[e.key % _colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${e.value.key}  ${e.value.value.toStringAsFixed(1)}%',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioHeroCard extends StatelessWidget {
  final InvestmentState state;
  const _PortfolioHeroCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final gain = state.totalGain;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gain >= 0
              ? [AppTheme.income.withAlpha(40), AppTheme.cardSurface.withAlpha(200)]
              : [AppTheme.expense.withAlpha(40), AppTheme.cardSurface.withAlpha(200)],
        ),
        border: Border.all(
          color: (gain >= 0 ? AppTheme.income : AppTheme.expense).withAlpha(60),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LabelValue(
                    label: 'Invested', value: Money.format(state.totalInvested)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LabelValue(
                    label: 'Current Value',
                    value: Money.format(state.totalCurrentValue)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Gain/Loss',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '${gain >= 0 ? '+' : ''}${Money.format(gain)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: gain >= 0 ? AppTheme.income : AppTheme.expense,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _Pill(
                      '${state.gainPercent >= 0 ? '+' : ''}${state.gainPercent.toStringAsFixed(1)}%',
                      gain >= 0 ? AppTheme.income : AppTheme.expense,
                    ),
                    const SizedBox(height: 4),
                    _Pill(
                      'XIRR ${state.xirr.toStringAsFixed(1)}%',
                      AppTheme.accent,
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

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _AssetTypeGroup extends StatelessWidget {
  final AssetType type;
  final List<Investment> items;
  final WidgetRef ref;
  const _AssetTypeGroup(
      {required this.type, required this.items, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(type.label.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
          ...items.map((inv) => _InvestmentCard(
                investment: inv,
                ref: ref,
              )),
        ],
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;
  final WidgetRef ref;
  const _InvestmentCard({required this.investment, required this.ref});

  @override
  Widget build(BuildContext context) {
    final gain = investment.absoluteGain;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InvestmentDetailScreen(investment: investment),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(200),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: gain >= 0
                    ? AppTheme.income.withAlpha(20)
                    : AppTheme.expense.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(investment.assetType),
                size: 20,
                color: gain >= 0 ? AppTheme.income : AppTheme.expense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(investment.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Invested ${Money.format(investment.totalInvested)}',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Money.format(investment.currentValue),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary)),
                Text(
                  '${gain >= 0 ? '+' : ''}${investment.gainPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: gain >= 0 ? AppTheme.income : AppTheme.expense,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(AssetType type) {
    switch (type) {
      case AssetType.stocks:
        return Icons.show_chart;
      case AssetType.mutualFund:
        return Icons.account_balance;
      case AssetType.sip:
        return Icons.repeat;
      case AssetType.gold:
        return Icons.monetization_on;
      case AssetType.fd:
        return Icons.savings;
      case AssetType.ppf:
        return Icons.shield;
      case AssetType.nps:
        return Icons.elderly;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.bonds:
        return Icons.link;
      case AssetType.other:
        return Icons.more_horiz;
    }
  }
}
