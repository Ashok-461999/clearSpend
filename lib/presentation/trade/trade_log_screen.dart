import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/trade.dart';
import 'trade_form_screen.dart';

enum _SortField { date, pnl, instrument }

class TradeLogScreen extends ConsumerStatefulWidget {
  const TradeLogScreen({super.key});

  @override
  ConsumerState<TradeLogScreen> createState() => _TradeLogScreenState();
}

class _TradeLogScreenState extends ConsumerState<TradeLogScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  TradeType? _localTypeFilter;
  TradeStatus? _localStatusFilter;
  _SortField _sortField = _SortField.date;
  bool _sortAsc = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Trade> _processTrades(List<Trade> trades) {
    var result = trades.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) => t.instrumentName.toLowerCase().contains(q)).toList();
    }

    if (_localTypeFilter != null) {
      result = result.where((t) => t.tradeType == _localTypeFilter).toList();
    }

    if (_localStatusFilter != null) {
      result = result.where((t) => t.status == _localStatusFilter).toList();
    }

    final cmp = _sortField == _SortField.date
        ? (Trade a, Trade b) => a.entryDate.compareTo(b.entryDate)
        : _sortField == _SortField.pnl
            ? (Trade a, Trade b) => a.netPnl.compareTo(b.netPnl)
            : (Trade a, Trade b) =>
                a.instrumentName.compareTo(b.instrumentName);

    result.sort((a, b) => _sortAsc ? cmp(a, b) : cmp(b, a));
    return result;
  }

  Duration _holdingPeriod(Trade t) {
    final end = t.exitDate ?? DateTime.now();
    return end.difference(t.entryDate);
  }

  String _formatDuration(Duration d) {
    if (d.inDays >= 365) {
      final y = d.inDays ~/ 365;
      return '${y}y';
    }
    if (d.inDays >= 30) {
      final m = d.inDays ~/ 30;
      return '${m}mo';
    }
    if (d.inDays >= 7) {
      final w = d.inDays ~/ 7;
      return '${w}w';
    }
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }

  Duration _avgHoldingPeriod(List<Trade> trades) {
    if (trades.isEmpty) return Duration.zero;
    final total = trades.fold<int>(0, (s, t) => s + _holdingPeriod(t).inMinutes);
    return Duration(minutes: total ~/ trades.length);
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _localTypeFilter != null ||
      _localStatusFilter != null;

  void _clearFilters() {
    setState(() {
      _searchCtrl.clear();
      _searchQuery = '';
      _localTypeFilter = null;
      _localStatusFilter = null;
    });
    ref.read(tradeControllerProvider.notifier).setFilterStatus(null);
    ref.read(tradeControllerProvider.notifier).setFilterType(null);
  }

  Future<void> _deleteTrade(BuildContext context, Trade trade) async {
    final id = trade.id;
    if (id == null) return;
    ref.read(tradeControllerProvider.notifier).deleteTrade(id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${trade.instrumentName} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(tradeControllerProvider.notifier).addTrade(trade);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tradeControllerProvider);
    final raw = state.allTrades;
    final displayed = _processTrades(raw);

    final closedCount = state.closedTrades.length;
    final winRate = state.winRate;
    final totalPnl = state.totalPnl;
    final avgHold = _avgHoldingPeriod(closedCount > 0 ? state.closedTrades : raw);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Log'),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear filters',
              onPressed: _clearFilters,
            ),
          PopupMenuButton<_SortField>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (f) => setState(() {
              if (_sortField == f) {
                _sortAsc = !_sortAsc;
              } else {
                _sortField = f;
                _sortAsc = f == _SortField.date ? false : true;
              }
            }),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _SortField.date,
                child: Row(
                  children: [
                    Icon(
                      _sortField == _SortField.date
                          ? (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.calendar_today_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Date'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortField.pnl,
                child: Row(
                  children: [
                    Icon(
                      _sortField == _SortField.pnl
                          ? (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.trending_up_outlined,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('P&L'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: _SortField.instrument,
                child: Row(
                  children: [
                    Icon(
                      _sortField == _SortField.instrument
                          ? (_sortAsc ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.text_fields,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text('Instrument'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TradeFormScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchFilterBar(
            searchCtrl: _searchCtrl,
            searchQuery: _searchQuery,
            localTypeFilter: _localTypeFilter,
            localStatusFilter: _localStatusFilter,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onTypeChanged: (v) => setState(() => _localTypeFilter = v),
            onStatusChanged: (v) => setState(() => _localStatusFilter = v),
          ),
          Expanded(
            child: displayed.isEmpty
                ? _EmptyTradeState(onAdd: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TradeFormScreen()),
                    );
                  })
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: displayed.length,
                    itemBuilder: (_, i) => _TradeCard(
                      trade: displayed[i],
                      ref: ref,
                      onDelete: () => _deleteTrade(context, displayed[i]),
                    ),
                  ),
          ),
          _SummaryBar(
            totalTrades: raw.length,
            closedTrades: closedCount,
            winRate: winRate,
            totalPnl: totalPnl,
            avgHoldingPeriod: avgHold,
          ),
        ],
      ),
    );
  }
}

class _SearchFilterBar extends StatelessWidget {
  final TextEditingController searchCtrl;
  final String searchQuery;
  final TradeType? localTypeFilter;
  final TradeStatus? localStatusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TradeType?> onTypeChanged;
  final ValueChanged<TradeStatus?> onStatusChanged;

  const _SearchFilterBar({
    required this.searchCtrl,
    required this.searchQuery,
    required this.localTypeFilter,
    required this.localStatusFilter,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          TextField(
            controller: searchCtrl,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search instrument...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchCtrl.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.cardSurface.withAlpha(150),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
              child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip<TradeStatus>(
                  label: 'All',
                  selected: localStatusFilter == null,
                  onTap: () => onStatusChanged(null),
                ),
                _FilterChip<TradeStatus>(
                  label: 'Open',
                  selected: localStatusFilter == TradeStatus.open,
                  activeColor: AppTheme.warning,
                  onTap: () =>
                      onStatusChanged(TradeStatus.open),
                ),
                _FilterChip<TradeStatus>(
                  label: 'Closed',
                  selected: localStatusFilter == TradeStatus.closed,
                  activeColor: AppTheme.income,
                  onTap: () =>
                      onStatusChanged(TradeStatus.closed),
                ),
                const _DividerDot(),
                _FilterChip<TradeType>(
                  label: TradeType.equity.label,
                  selected: localTypeFilter == TradeType.equity,
                  activeColor: AppTheme.primary,
                  onTap: () => onTypeChanged(TradeType.equity),
                ),
                _FilterChip<TradeType>(
                  label: TradeType.futures.label,
                  selected: localTypeFilter == TradeType.futures,
                  activeColor: AppTheme.accent,
                  onTap: () => onTypeChanged(TradeType.futures),
                ),
                _FilterChip<TradeType>(
                  label: TradeType.options.label,
                  selected: localTypeFilter == TradeType.options,
                  activeColor: AppTheme.warning,
                  onTap: () => onTypeChanged(TradeType.options),
                ),
                _FilterChip<TradeType>(
                  label: TradeType.crypto.label,
                  selected: localTypeFilter == TradeType.crypto,
                  activeColor: AppTheme.expense,
                  onTap: () => onTypeChanged(TradeType.crypto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip<T> extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : AppTheme.cardSurface.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _EmptyTradeState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTradeState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No trades yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your trades and\nwatch your performance grow.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withAlpha(200),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Your First Trade'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final int totalTrades;
  final int closedTrades;
  final double winRate;
  final int totalPnl;
  final Duration avgHoldingPeriod;

  const _SummaryBar({
    required this.totalTrades,
    required this.closedTrades,
    required this.winRate,
    required this.totalPnl,
    required this.avgHoldingPeriod,
  });

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final pnlColor = totalPnl >= 0 ? AppTheme.income : AppTheme.expense;
    final pnlStr = totalPnl >= 0
        ? '+${Money.format(totalPnl)}'
        : Money.format(totalPnl);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          _SummaryItem(
            label: 'Trades',
            value: '$totalTrades',
            icon: Icons.swap_vert_rounded,
          ),
          _SummaryItem(
            label: 'Win',
            value: '${winRate.toStringAsFixed(0)}%',
            icon: Icons.check_circle_outline,
            valueColor: AppTheme.income,
          ),
          _SummaryItem(
            label: 'P&L',
            value: pnlStr,
            icon: Icons.trending_up_rounded,
            valueColor: pnlColor,
          ),
          _SummaryItem(
            label: 'Avg Hold',
            value: _formatDuration(avgHoldingPeriod),
            icon: Icons.access_time_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary.withAlpha(180)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}

class _TradeCard extends StatelessWidget {
  final Trade trade;
  final WidgetRef ref;
  final VoidCallback onDelete;

  const _TradeCard({
    required this.trade,
    required this.ref,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = trade.status == TradeStatus.open;
    final pnlColor = trade.netPnl >= 0 ? AppTheme.income : AppTheme.expense;
    final duration = trade.exitDate != null
        ? trade.exitDate!.difference(trade.entryDate)
        : DateTime.now().difference(trade.entryDate);

    return Dismissible(
      key: ValueKey(trade.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.expense.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppTheme.expense, size: 28),
      ),
      confirmDismiss: (dir) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(200),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? AppTheme.border : pnlColor.withAlpha(60),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isOpen ? () => _closeTrade(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _typeColor(trade.tradeType).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        trade.tradeType.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _typeColor(trade.tradeType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trade.instrumentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface.withAlpha(150),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qty ${_formatQty(trade.quantity)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isOpen)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'OPEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                        label: 'Entry',
                        value: Money.format(trade.entryPrice)),
                    const SizedBox(width: 8),
                    if (trade.exitPrice != null)
                      _InfoChip(
                          label: 'Exit',
                          value: Money.format(trade.exitPrice!)),
                    if (trade.brokerage > 0) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: 'Brokerage',
                          value: Money.format(trade.brokerage)),
                    ],
                    const Spacer(),
                    if (!isOpen)
                      Text(
                        trade.netPnl >= 0
                            ? '+${Money.format(trade.netPnl)}'
                            : Money.format(trade.netPnl),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: pnlColor,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: AppTheme.textSecondary.withAlpha(150)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(trade.entryDate),
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    if (trade.exitDate != null) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward,
                          size: 11, color: AppTheme.textSecondary.withAlpha(120)),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(trade.exitDate!),
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Icon(Icons.access_time,
                        size: 12, color: AppTheme.textSecondary.withAlpha(150)),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(1);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatDuration(Duration d) {
    if (d.inDays >= 365) {
      final y = d.inDays ~/ 365;
      final rem = d.inDays % 365;
      if (rem >= 30) return '${y}y ${rem ~/ 30}mo';
      return '${y}y';
    }
    if (d.inDays >= 30) {
      final m = d.inDays ~/ 30;
      final rem = d.inDays % 30;
      if (rem > 0) return '${m}mo ${rem}d';
      return '${m}mo';
    }
    if (d.inDays >= 7) {
      final w = d.inDays ~/ 7;
      return '${w}w';
    }
    if (d.inDays > 0) return '${d.inDays}d';
    if (d.inHours > 0) return '${d.inHours}h';
    return '${d.inMinutes}m';
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
        return AppTheme.expense;
    }
  }

  Future<void> _closeTrade(BuildContext context) async {
    final exitCtrl = TextEditingController();
    final dateCtrl = TextEditingController(
      text:
          '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
    final exitPrice = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Close Trade',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: exitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Exit price (₹)',
                prefixText: '₹ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final price = Money.parseToMinor(exitCtrl.text);
              if (price != null) Navigator.pop(ctx, price);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (exitPrice != null && trade.id != null) {
      ref
          .read(tradeControllerProvider.notifier)
          .closeTrade(trade.id!, exitPrice, DateTime.now());
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ',
              style:
                  TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
