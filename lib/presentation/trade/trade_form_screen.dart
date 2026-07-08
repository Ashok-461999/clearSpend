import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/trade.dart';

final _popularInstruments = [
  'RELIANCE', 'TCS', 'HDFCBANK', 'INFY', 'ICICIBANK',
  'HINDUNILVR', 'ITC', 'SBIN', 'BHARTIARTL', 'KOTAKBANK',
  'LT', 'WIPRO', 'AXISBANK', 'BAJFINANCE', 'MARUTI',
  'TITAN', 'ASIANPAINT', 'NESTLEIND', 'SUNPHARMA', 'ULTRACEMCO',
  'NIFTY 50', 'SENSEX', 'BANK NIFTY', 'FINNIFTY', 'MIDCP NIFTY',
  'BTC-INR', 'ETH-INR', 'SOL-INR', 'XRP-INR', 'ADA-INR',
  'TATAMOTORS', 'TATASTEEL', 'JSWSTEEL', 'POWERGRID', 'NTPC',
  'HCLTECH', 'TECHM', 'BAJAJFINSV', 'DMART', 'ZOMATO',
  'HAL', 'BEL', 'VEDL', 'COALINDIA', 'ADANIENT',
  'AIRTEL', 'M&M', 'TRENT', 'DIXON', 'IRFC',
];

const _tradeTypeDescriptions = {
  TradeType.equity: 'Delivery based — settle T+1, hold any duration',
  TradeType.futures: 'Expiry based — squared off on expiry date',
  TradeType.options: 'Premium based — net premium paid/received',
  TradeType.crypto: '24/7 — trade anytime, no expiry',
};

const _brokeragePresets = [0, 20, 50];

class TradeFormScreen extends ConsumerStatefulWidget {
  final Trade? existing;
  const TradeFormScreen({super.key, this.existing});
  @override
  ConsumerState<TradeFormScreen> createState() => _TradeFormScreenState();
}

class _TradeFormScreenState extends ConsumerState<TradeFormScreen> {
  final _instCtrl = TextEditingController();
  final _entryCtrl = TextEditingController();
  final _exitCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _brokerageCtrl = TextEditingController();
  final _instFocus = FocusNode();

  TradeType _type = TradeType.equity;
  DateTime _entryDate = DateTime.now();
  TimeOfDay _entryTime = TimeOfDay.now();
  DateTime? _exitDate;
  TimeOfDay? _exitTime;
  int? _customBrokeragePreset;

  String _instQuery = '';
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    if (t != null) {
      _instCtrl.text = t.instrumentName;
      _entryCtrl.text = Money.toEditString(t.entryPrice);
      _qtyCtrl.text = t.quantity.toString();
      _brokerageCtrl.text = Money.toEditString(t.brokerage);
      _type = t.tradeType;
      _entryDate = t.entryDate;
      _entryTime = TimeOfDay.fromDateTime(t.entryDate);
      if (t.exitDate != null) {
        _exitDate = t.exitDate;
        _exitTime = TimeOfDay.fromDateTime(t.exitDate!);
      }
      if (t.exitPrice != null) {
        _exitCtrl.text = Money.toEditString(t.exitPrice!);
      }
    }
    _instFocus.addListener(_onInstFocusChanged);
    _instCtrl.addListener(_onInstChanged);
  }

  @override
  void dispose() {
    _instCtrl.dispose();
    _entryCtrl.dispose();
    _exitCtrl.dispose();
    _qtyCtrl.dispose();
    _brokerageCtrl.dispose();
    _instFocus.dispose();
    super.dispose();
  }

  void _onInstChanged() {
    final q = _instCtrl.text.trim().toUpperCase();
    if (q.isNotEmpty && _instFocus.hasFocus) {
      setState(() {
        _instQuery = q;
        _suggestions = _popularInstruments
            .where((s) => s.startsWith(q))
            .take(8)
            .toList();
      });
    } else {
      setState(() {
        _instQuery = '';
        _suggestions = [];
      });
    }
  }

  void _onInstFocusChanged() {
    if (!_instFocus.hasFocus) {
      setState(() => _suggestions = []);
    }
  }

  void _selectInstrument(String name) {
    setState(() {
      _instCtrl.text = name;
      _instQuery = '';
      _suggestions = [];
    });
    _instFocus.unfocus();
  }

  void _setBrokeragePreset(int value) {
    setState(() {
      _customBrokeragePreset = value;
      _brokerageCtrl.text = value == 0 ? '0' : value.toString();
    });
  }

  void _setCustomBrokerage() {
    setState(() => _customBrokeragePreset = null);
  }

  double? get _parsedEntry {
    final v = double.tryParse(_entryCtrl.text.replaceAll(',', ''));
    if (v == null || v <= 0) return null;
    return v;
  }

  double? get _parsedExit {
    final t = _exitCtrl.text.replaceAll(',', '');
    if (t.isEmpty) return null;
    final v = double.tryParse(t);
    if (v == null || v <= 0) return null;
    return v;
  }

  double? get _parsedQty {
    final v = double.tryParse(_qtyCtrl.text);
    if (v == null || v <= 0) return null;
    return v;
  }

  double? get _totalInvestment {
    final price = _parsedEntry;
    final qty = _parsedQty;
    if (price == null || qty == null) return null;
    return price * qty;
  }

  double? get _totalExitValue {
    final price = _parsedExit;
    final qty = _parsedQty;
    if (price == null || qty == null) return null;
    return price * qty;
  }

  int? get _pnl {
    final entry = _parsedEntry;
    final exit = _parsedExit;
    final qty = _parsedQty;
    final rawBrokerage = double.tryParse(_brokerageCtrl.text.replaceAll(',', ''));
    if (entry == null || qty == null || exit == null) return null;
    final gross = (exit - entry) * qty;
    final brk = (rawBrokerage ?? 0) * 100;
    return (gross * 100).round() - brk.round();
  }

  Duration? get _holdingPeriod {
    if (_exitDate == null) return null;
    final entryDt = DateTime(
      _entryDate.year, _entryDate.month, _entryDate.day,
      _entryTime.hour, _entryTime.minute,
    );
    final exitDt = DateTime(
      _exitDate!.year, _exitDate!.month, _exitDate!.day,
      _exitTime!.hour, _exitTime!.minute,
    );
    return exitDt.difference(entryDt);
  }

  String _formatDuration(Duration d) {
    if (d.isNegative) return 'Exit before entry';
    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final mins = d.inMinutes.remainder(60);
    if (days > 0) return '$days d, $hours h, $mins m';
    if (hours > 0) return '$hours h, $mins m';
    return '$mins m';
  }

  Future<void> _pickDateTime(bool isEntry) async {
    final now = DateTime.now();
    final initialDate = isEntry ? _entryDate : (_exitDate ?? now);
    final initialTime = isEntry ? _entryTime : (_exitTime ?? TimeOfDay.now());

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null || !mounted) return;

    setState(() {
      if (isEntry) {
        _entryDate = date;
        _entryTime = time;
      } else {
        _exitDate = date;
        _exitTime = time;
      }
    });
  }

  String _formatDateTime(DateTime date, TimeOfDay time) {
    final m = time.minute.toString().padLeft(2, '0');
    final h = time.hour.toString().padLeft(2, '0');
    return '${date.day}/${date.month}/${date.year} $h:$m';
  }

  void _submit({bool asDraft = false}) {
    final entryPrice = Money.parseToMinor(_entryCtrl.text);
    final qty = double.tryParse(_qtyCtrl.text);
    final brokerage = Money.parseToMinor(_brokerageCtrl.text) ?? 0;
    if (_instCtrl.text.trim().isEmpty) {
      _showError('Enter instrument name');
      return;
    }
    if (entryPrice == null || entryPrice <= 0) {
      _showError('Enter valid entry price');
      return;
    }
    if (qty == null || qty <= 0) {
      _showError('Enter valid quantity');
      return;
    }

    final exitPrice = Money.parseToMinor(_exitCtrl.text);
    final exitDate = _exitDate != null
        ? DateTime(
            _exitDate!.year, _exitDate!.month, _exitDate!.day,
            _exitTime!.hour, _exitTime!.minute,
          )
        : null;

    final status = asDraft
        ? TradeStatus.open
        : (exitPrice != null && exitDate != null
            ? TradeStatus.closed
            : TradeStatus.open);

    final trade = Trade(
      id: widget.existing?.id,
      instrumentName: _instCtrl.text.trim(),
      tradeType: _type,
      entryPrice: entryPrice,
      quantity: qty,
      brokerage: brokerage,
      entryDate: DateTime(
        _entryDate.year, _entryDate.month, _entryDate.day,
        _entryTime.hour, _entryTime.minute,
      ),
      exitDate: exitDate,
      exitPrice: exitPrice,
      status: status,
    );

    if (asDraft) {
      ref.read(tradeControllerProvider.notifier).addTrade(trade);
    } else {
      if (widget.existing != null) {
        ref.read(tradeControllerProvider.notifier).addTrade(trade);
      } else {
        ref.read(tradeControllerProvider.notifier).addTrade(trade);
      }
    }
    Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalInv = _totalInvestment;
    final pnl = _pnl;
    final holding = _holdingPeriod;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? 'Edit Trade' : 'Add Trade'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _submit(asDraft: true),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Draft'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInstrumentSearch(),
            const SizedBox(height: 20),
            _buildTradeTypeSelector(),
            const SizedBox(height: 20),
            _buildPriceSection(),
            const SizedBox(height: 12),
            _buildLiveValue(totalInv),
            const SizedBox(height: 20),
            _buildQuantitySection(),
            const SizedBox(height: 20),
            _buildBrokerageSection(),
            const SizedBox(height: 20),
            _buildDateSection(),
            if (holding != null) ...[
              const SizedBox(height: 8),
              _buildHoldingPeriod(holding),
            ],
            const SizedBox(height: 20),
            _buildPnLPreview(pnl),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrumentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Instrument Name'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg.withAlpha(100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              TextField(
                controller: _instCtrl,
                focusNode: _instFocus,
                decoration: const InputDecoration(
                  hintText: 'Search stocks, indices, crypto…',
                  prefixIcon: Icon(Icons.search, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 0.5, color: AppTheme.border,
                    ),
                    itemBuilder: (ctx, i) {
                      final s = _suggestions[i];
                      final idx = s.indexOf(_instQuery);
                      return ListTile(
                        dense: true,
                        leading: Icon(Icons.trending_up,
                            size: 18, color: AppTheme.primary),
                        title: idx >= 0
                            ? RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 14),
                                  children: [
                                    TextSpan(text: s.substring(0, idx)),
                                    TextSpan(
                                      text: s.substring(
                                          idx, idx + _instQuery.length),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.accent),
                                    ),
                                    TextSpan(
                                        text: s.substring(
                                            idx + _instQuery.length)),
                                  ],
                                ),
                              )
                            : Text(s,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary)),
                        onTap: () => _selectInstrument(s),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTradeTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Trade Type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TradeType.values.map((t) {
            final sel = _type == t;
            return GestureDetector(
              onTap: () => setState(() => _type = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.accent.withAlpha(30)
                      : AppTheme.cardGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? AppTheme.accent : AppTheme.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.label,
                        style: TextStyle(
                            color: sel
                                ? AppTheme.accent
                                : AppTheme.textPrimary,
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 140,
                      child: Text(
                        _tradeTypeDescriptions[t] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: sel
                              ? AppTheme.accent.withAlpha(200)
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Expanded(
          child: _buildField(_entryCtrl, 'Entry Price (₹)', '0.00',
              prefix: '₹ ',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {})),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildField(_exitCtrl, 'Exit Price (₹)', 'Optional',
              prefix: '₹ ',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {})),
        ),
      ],
    );
  }

  Widget _buildLiveValue(double? totalInv) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: totalInv != null
          ? Container(
              key: const ValueKey('invested'),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGlass,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withAlpha(60)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance,
                      size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  const Text('Total Investment',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const Spacer(),
                  Text(
                    '₹ ${_entryCtrl.text.isEmpty ? '0' : _entryCtrl.text} × ${_qtyCtrl.text.isEmpty ? '0' : _qtyCtrl.text} = ₹ ${totalInv.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildQuantitySection() {
    return _buildField(_qtyCtrl, 'Quantity', 'e.g. 10, 100, 1.5',
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() {}));
  }

  Widget _buildBrokerageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Brokerage / DP Charges'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final p in _brokeragePresets) ...[
              _buildPresetChip('₹$p', p),
              const SizedBox(width: 8),
            ],
            _buildPresetChip('Custom', null),
          ],
        ),
        const SizedBox(height: 8),
        _buildField(_brokerageCtrl, '', '0.00',
            prefix: '₹ ',
            keyboardType: TextInputType.number,
            onChanged: (_) {
              setState(() => _customBrokeragePreset = null);
            }),
      ],
    );
  }

  Widget _buildPresetChip(String label, int? value) {
    final sel = _customBrokeragePreset == value;
    return GestureDetector(
      onTap: () {
        if (value != null) {
          _setBrokeragePreset(value);
        } else {
          _setCustomBrokerage();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel
              ? AppTheme.accent.withAlpha(30)
              : AppTheme.cardGlass,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: sel ? AppTheme.accent : AppTheme.border,
            width: sel ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? AppTheme.accent : AppTheme.textSecondary,
            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Entry & Exit Dates'),
        const SizedBox(height: 8),
        _buildDateRow(
          icon: Icons.login,
          label: 'Entry',
          date: _entryDate,
          time: _entryTime,
          color: AppTheme.income,
          onTap: () => _pickDateTime(true),
        ),
        const SizedBox(height: 8),
        _buildDateRow(
          icon: Icons.logout,
          label: 'Exit',
          date: _exitDate,
          time: _exitTime,
          color: AppTheme.warning,
          onTap: () => _pickDateTime(false),
          isOptional: true,
          onClear: _exitDate != null
              ? () => setState(() {
                    _exitDate = null;
                    _exitTime = null;
                  })
              : null,
        ),
      ],
    );
  }

  Widget _buildDateRow({
    required IconData icon,
    required String label,
    DateTime? date,
    TimeOfDay? time,
    required Color color,
    required VoidCallback onTap,
    bool isOptional = false,
    VoidCallback? onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          Text(
            _formatDateTime(date ?? DateTime.now(), time ?? const TimeOfDay(hour: 0, minute: 0)),
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
          if (isOptional && onClear != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close,
                  size: 14, color: AppTheme.textSecondary),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.edit_calendar,
                size: 16, color: isOptional ? AppTheme.warning : AppTheme.primary),
            label: Text(
              isOptional && date == _exitDate && _exitDate == null
                  ? 'Set'
                  : 'Change',
              style: TextStyle(
                  color:
                      isOptional ? AppTheme.warning : AppTheme.primary,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoldingPeriod(Duration holding) {
    final isNeg = holding.isNegative;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isNeg
            ? AppTheme.expense.withAlpha(20)
            : AppTheme.primaryGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNeg
              ? AppTheme.expense.withAlpha(80)
              : AppTheme.primary.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isNeg ? Icons.error_outline : Icons.timer_outlined,
            size: 18,
            color: isNeg ? AppTheme.expense : AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            isNeg ? 'Exit date is before entry date' : 'Holding Period',
            style: TextStyle(
              color: isNeg ? AppTheme.expense : AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            isNeg ? 'Invalid' : _formatDuration(holding),
            style: TextStyle(
              color: isNeg ? AppTheme.expense : AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPnLPreview(int? pnl) {
    final hasExit = _exitCtrl.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardSurface,
            pnl != null
                ? (pnl >= 0
                    ? AppTheme.income.withAlpha(15)
                    : AppTheme.expense.withAlpha(15))
                : AppTheme.cardSurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pnl != null
              ? (pnl >= 0
                  ? AppTheme.income.withAlpha(80)
                  : AppTheme.expense.withAlpha(80))
              : AppTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                pnl != null
                    ? (pnl >= 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward)
                    : Icons.show_chart,
                size: 20,
                color: pnl != null
                    ? (pnl >= 0 ? AppTheme.income : AppTheme.expense)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                hasExit ? 'P&L Preview' : 'Current Value',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              if (hasExit && pnl != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: pnl >= 0
                        ? AppTheme.income.withAlpha(25)
                        : AppTheme.expense.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pnl >= 0 ? 'PROFIT' : 'LOSS',
                    style: TextStyle(
                      color: pnl >= 0
                          ? AppTheme.income
                          : AppTheme.expense,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (!hasExit && _totalInvestment != null)
            _buildPnLRow(
              'Invested',
              '₹ ${_totalInvestment!.toStringAsFixed(2)}',
              AppTheme.textPrimary,
            ),
          if (_parsedEntry != null && _parsedQty != null) ...[
            _buildPnLRow(
              'Entry Value',
              '₹ ${(_parsedEntry! * _parsedQty!).toStringAsFixed(2)}',
              AppTheme.textSecondary,
            ),
          ],
          if (hasExit && _totalExitValue != null)
            _buildPnLRow(
              'Exit Value',
              '₹ ${_totalExitValue!.toStringAsFixed(2)}',
              AppTheme.textSecondary,
            ),
          if (hasExit && pnl != null) ...[
            const Divider(height: 20, color: AppTheme.border),
            _buildPnLRow(
              'Net P&L',
              '${pnl >= 0 ? '+' : ''}₹ ${(pnl / 100).toStringAsFixed(2)}',
              pnl >= 0 ? AppTheme.income : AppTheme.expense,
              bold: true,
            ),
            if (_parsedEntry != null && _parsedEntry! > 0)
              _buildPnLRow(
                'Return %',
                '${((pnl / 100) / (_parsedEntry! * _parsedQty!) * 100).toStringAsFixed(2)}%',
                pnl >= 0 ? AppTheme.income : AppTheme.expense,
              ),
          ],
          if (!hasExit && _totalInvestment != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Add exit price to see P&L',
                style: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(150),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          if (pnl == null && _entryCtrl.text.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Enter price & quantity to see preview',
                style: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(150),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPnLRow(String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        FilledButton(
          onPressed: _submit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.existing != null
                    ? Icons.update
                    : Icons.check_circle_outline,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                widget.existing != null ? 'Update Trade' : 'Save Trade',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _submit(asDraft: true),
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save as Draft'),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(text,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary));
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint, {
    String? prefix,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg.withAlpha(100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
