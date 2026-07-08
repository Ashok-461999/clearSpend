import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/investment.dart';

enum SortMode { nameAsc, gainHighToLow, gainLowToHigh, assetType }

class PriceUpdateScreen extends ConsumerStatefulWidget {
  const PriceUpdateScreen({super.key});
  @override
  ConsumerState<PriceUpdateScreen> createState() => _PriceUpdateScreenState();
}

class _PriceUpdateScreenState extends ConsumerState<PriceUpdateScreen> {
  final _controllers = <int, TextEditingController>{};
  final _bulkPercentController = TextEditingController();
  final _searchController = TextEditingController();

  SortMode _sortMode = SortMode.nameAsc;
  AssetType? _filterAssetType;
  bool _showOnlyProfitable = false;
  bool _showOnlyLoss = false;
  final _selectedIds = <int>{};
  bool _selectAll = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _bulkPercentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  DateTime? _latestRefresh(List<Investment> investments) {
    DateTime? latest;
    for (final inv in investments) {
      if (inv.lastUpdatedAt != null) {
        if (latest == null || inv.lastUpdatedAt!.isAfter(latest)) {
          latest = inv.lastUpdatedAt;
        }
      }
    }
    return latest;
  }

  String? _earliestRefresh(List<Investment> investments) {
    DateTime? earliest;
    for (final inv in investments) {
      if (inv.lastUpdatedAt != null) {
        if (earliest == null || inv.lastUpdatedAt!.isBefore(earliest)) {
          earliest = inv.lastUpdatedAt;
        }
      }
    }
    if (earliest == null) return null;
    final latest = _latestRefresh(investments);
    if (latest == null || earliest == latest) return null;
    return _formatTimestamp(earliest);
  }

  int _countProfitable(List<Investment> list) =>
      list.where((inv) => inv.isProfitable).length;

  int _countLoss(List<Investment> list) =>
      list.where((inv) => !inv.isProfitable).length;

  List<Investment> _processList(List<Investment> all) {
    var list = List<Investment>.from(all);

    if (_filterAssetType != null) {
      list = list.where((inv) => inv.assetType == _filterAssetType).toList();
    }
    if (_showOnlyProfitable) {
      list = list.where((inv) => inv.isProfitable).toList();
    }
    if (_showOnlyLoss) {
      list = list.where((inv) => !inv.isProfitable).toList();
    }
    if (_searchController.text.trim().isNotEmpty) {
      final q = _searchController.text.trim().toLowerCase();
      list = list.where((inv) => inv.name.toLowerCase().contains(q)).toList();
    }

    switch (_sortMode) {
      case SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case SortMode.gainHighToLow:
        list.sort((a, b) => b.gainPercent.compareTo(a.gainPercent));
      case SortMode.gainLowToHigh:
        list.sort((a, b) => a.gainPercent.compareTo(b.gainPercent));
      case SortMode.assetType:
        list.sort((a, b) {
          final cmp = a.assetType.label.compareTo(b.assetType.label);
          if (cmp != 0) return cmp;
          return a.name.compareTo(b.name);
        });
    }
    return list;
  }

  void _applyBulkPercent() {
    final percentText = _bulkPercentController.text.trim();
    if (percentText.isEmpty) return;
    final percent = double.tryParse(percentText);
    if (percent == null || percent == 0) return;

    final investments =
        ref.read(investmentControllerProvider).allInvestments;
    final targets = _selectedIds.isNotEmpty
        ? investments
            .where((inv) => inv.id != null && _selectedIds.contains(inv.id))
            .toList()
        : investments.where((inv) => inv.id != null).toList();

    if (targets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No investments selected')),
      );
      return;
    }

    final notifier = ref.read(investmentControllerProvider.notifier);
    int updated = 0;
    for (final inv in targets) {
      if (inv.id == null) continue;
      final newPrice = (inv.currentPricePerUnit * (1 + percent / 100)).round();
      if (newPrice <= 0) continue;
      notifier.updatePrice(inv.id!, newPrice);
      // update the controller text too
      _controllers[inv.id!]?.text = Money.toEditString(newPrice);
      updated++;
    }

    _bulkPercentController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '$updated investment(s) updated by $percent%'),
        duration: const Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  void _toggleSelectAll(List<Investment> displayed) {
    if (_selectAll) {
      _selectedIds.clear();
      _selectAll = false;
    } else {
      _selectedIds.clear();
      for (final inv in displayed) {
        if (inv.id != null) _selectedIds.add(inv.id!);
      }
      _selectAll = true;
    }
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _filterAssetType = null;
      _showOnlyProfitable = false;
      _showOnlyLoss = false;
      _searchController.clear();
      _sortMode = SortMode.nameAsc;
    });
  }

  bool get _hasActiveFilters =>
      _filterAssetType != null ||
      _showOnlyProfitable ||
      _showOnlyLoss ||
      _searchController.text.trim().isNotEmpty ||
      _sortMode != SortMode.nameAsc;

  Widget _buildSummaryBar(List<Investment> all) {
    final profitable = _countProfitable(all);
    final loss = _countLoss(all);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _summaryBadge('${all.length}', 'Total', AppTheme.textPrimary),
          Container(
              width: 1,
              height: 24,
              color: AppTheme.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          _summaryBadge('$profitable', 'Profit', AppTheme.income),
          Container(
              width: 1,
              height: 24,
              color: AppTheme.border,
              margin: const EdgeInsets.symmetric(horizontal: 10)),
          _summaryBadge('$loss', 'Loss', AppTheme.expense),
          const Spacer(),
          if (_hasActiveFilters)
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.expense.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.expense.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 12, color: AppTheme.expense),
                    SizedBox(width: 3),
                    Text('Clear',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.expense,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String value, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()])),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildSortFilterBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(200),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: TextField(
              controller: _searchController,
              style:
                  const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search investments...',
                hintStyle:
                    TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                prefixIcon: Icon(Icons.search,
                    color: AppTheme.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
                suffixIcon: null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  'All',
                  _filterAssetType == null &&
                      !_showOnlyProfitable &&
                      !_showOnlyLoss,
                  () => setState(() {
                    _filterAssetType = null;
                    _showOnlyProfitable = false;
                    _showOnlyLoss = false;
                  }),
                ),
                ...AssetType.values.map((at) => _buildFilterChip(
                      at.label,
                      _filterAssetType == at,
                      () => setState(() => _filterAssetType = at),
                    )),
                const _FilterDivider(),
                _buildFilterChip(
                  'Profit',
                  _showOnlyProfitable,
                  () => setState(() {
                    _showOnlyProfitable = !_showOnlyProfitable;
                    if (_showOnlyProfitable) _showOnlyLoss = false;
                  }),
                  icon: Icons.trending_up,
                ),
                _buildFilterChip(
                  'Loss',
                  _showOnlyLoss,
                  () => setState(() {
                    _showOnlyLoss = !_showOnlyLoss;
                    if (_showOnlyLoss) _showOnlyProfitable = false;
                  }),
                  icon: Icons.trending_down,
                ),
                const _FilterDivider(),
                _buildSortDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withAlpha(25)
                : AppTheme.cardSurface.withAlpha(150),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppTheme.primary.withAlpha(100)
                  : AppTheme.border,
              width: selected ? 1.2 : 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 13,
                    color:
                        selected ? AppTheme.primary : AppTheme.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      selected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Icon(Icons.check,
                      size: 12, color: AppTheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortMode>(
          value: _sortMode,
          isDense: true,
          dropdownColor: AppTheme.cardSurface,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
          icon:
              const Icon(Icons.swap_vert, size: 14, color: AppTheme.textSecondary),
          onChanged: (val) {
            if (val != null) setState(() => _sortMode = val);
          },
          items: const [
            DropdownMenuItem(
                value: SortMode.nameAsc,
                child: Text('Name A-Z', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(
                value: SortMode.gainHighToLow,
                child: Text('Gain High-Low', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(
                value: SortMode.gainLowToHigh,
                child: Text('Gain Low-High', style: TextStyle(fontSize: 11))),
            DropdownMenuItem(
                value: SortMode.assetType,
                child: Text('Asset Type', style: TextStyle(fontSize: 11))),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshIndicator(List<Investment> all) {
    final latest = _latestRefresh(all);
    if (latest == null) return const SizedBox.shrink();
    final earliestStr = _earliestRefresh(all);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primary.withAlpha(35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Last price refresh: '),
                  TextSpan(
                    text: _formatTimestamp(latest),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (earliestStr != null)
                    TextSpan(
                      text: '  (from $earliestStr)',
                      style: TextStyle(
                        color: AppTheme.primary.withAlpha(150),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkUpdateBar(int totalCount) {
    final displayed = _processList(
        ref.watch(investmentControllerProvider).allInvestments);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up,
                  color: AppTheme.accent, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Bulk Update',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              if (_selectedIds.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.accent.withAlpha(80)),
                  ),
                  child: Text(
                    '${_selectedIds.length} selected',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleSelectAll(displayed),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _selectAll
                        ? AppTheme.accent.withAlpha(25)
                        : AppTheme.bg.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectAll
                          ? AppTheme.accent.withAlpha(100)
                          : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    _selectAll ? 'Deselect' : 'Select All',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _selectAll
                          ? AppTheme.accent
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bg.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: _bulkPercentController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                    style: const TextStyle(
                        color: AppTheme.textPrimary, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'e.g. +5 or -3',
                      hintStyle: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                      prefixIcon: Icon(Icons.percent,
                          color: AppTheme.textSecondary, size: 16),
                    ),
                    onSubmitted: (_) => _applyBulkPercent(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _applyBulkPercent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.accent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(80),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        children: [
          SizedBox(width: 24),
          Expanded(
            flex: 3,
            child: Text('Investment',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: Text('Buy Price',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: Text('Current',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: Text('Gain %',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: Text('Updated',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentRow(Investment inv, int index) {
    final gainPct = inv.gainPercent;
    final isProfit = inv.isProfitable;
    final isSelected =
        inv.id != null && _selectedIds.contains(inv.id);

    final Color rowBg;
    final Color borderColor;
    if (isProfit) {
      rowBg = AppTheme.income.withAlpha(10);
      borderColor = AppTheme.income.withAlpha(35);
    } else if (gainPct == 0) {
      rowBg = Colors.transparent;
      borderColor = AppTheme.border;
    } else {
      rowBg = AppTheme.expense.withAlpha(10);
      borderColor = AppTheme.expense.withAlpha(35);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.accent.withAlpha(12)
            : rowBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.accent.withAlpha(80)
              : borderColor,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (inv.id != null) {
            setState(() {
              if (_selectedIds.contains(inv.id)) {
                _selectedIds.remove(inv.id);
                _selectAll = false;
              } else {
                _selectedIds.add(inv.id!);
              }
            });
          }
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Icon(
                  isSelected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 18,
                  color: isSelected
                      ? AppTheme.accent
                      : AppTheme.textSecondary.withAlpha(120),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inv.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppTheme.textPrimary),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(15),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(inv.assetType.label,
                              style: const TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500)),
                        ),
                        if (inv.units > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${inv.units.toStringAsFixed(2)} units',
                            style: const TextStyle(
                                fontSize: 8,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  Money.format(inv.buyPricePerUnit),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppTheme.bg.withAlpha(80),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: inv.id != null
                        ? _controllers[inv.id]
                        : null,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontSize: 9,
                        color: AppTheme.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 5, vertical: 6),
                      isDense: true,
                    ),
                    onSubmitted: (val) {
                      if (inv.id == null) return;
                      final price = Money.parseToMinor(val);
                      if (price != null) {
                        ref
                            .read(investmentControllerProvider
                                .notifier)
                            .updatePrice(inv.id!, price);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${inv.name} → ${Money.format(price)}'),
                            duration:
                                const Duration(seconds: 1),
                            behavior:
                                SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${gainPct >= 0 ? '+' : ''}${gainPct.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isProfit
                            ? AppTheme.income
                            : AppTheme.expense,
                        fontFeatures: const [
                          FontFeature.tabularFigures()
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      isProfit
                          ? '+${Money.format(inv.absoluteGain)}'
                          : '-${Money.format(inv.absoluteGain.abs())}',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: isProfit
                            ? AppTheme.income.withAlpha(150)
                            : AppTheme.expense.withAlpha(150),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  inv.lastUpdatedAt != null
                      ? _formatTimestamp(inv.lastUpdatedAt!)
                      : '--',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentControllerProvider);
    final allInvestments = state.allInvestments;

    for (final inv in allInvestments) {
      if (inv.id != null && !_controllers.containsKey(inv.id)) {
        _controllers[inv.id!] = TextEditingController(
          text: Money.toEditString(inv.currentPricePerUnit),
        );
      }
    }

    final processed = _processList(allInvestments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Prices'),
        actions: [
          TextButton(
            onPressed: () {
              final priceMap = <int, int>{};
              for (final inv in allInvestments) {
                if (inv.id == null) continue;
                final price =
                    Money.parseToMinor(_controllers[inv.id]!.text);
                if (price != null) {
                  priceMap[inv.id!] = price;
                }
              }
              if (priceMap.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('No valid prices to save')),
                );
                return;
              }
              ref
                  .read(investmentControllerProvider.notifier)
                  .bulkUpdatePrices(priceMap);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${priceMap.length} price(s) updated'),
                ),
              );
            },
            child: const Text('Save All',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildRefreshIndicator(allInvestments),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSummaryBar(allInvestments),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSortFilterBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child:
                _buildBulkUpdateBar(allInvestments.length),
          ),
          if (processed.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTableHeader(),
            ),
          Expanded(
            child: processed.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off,
                            size: 40,
                            color: AppTheme.textSecondary
                                .withAlpha(100)),
                        const SizedBox(height: 8),
                        const Text(
                          'No matching investments',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        if (_hasActiveFilters)
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear filters'),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    itemCount: processed.length,
                    itemBuilder: (_, i) =>
                        _buildInvestmentRow(processed[i], i),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterDivider extends StatelessWidget {
  const _FilterDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 1,
        height: 20,
        color: AppTheme.border,
      ),
    );
  }
}
