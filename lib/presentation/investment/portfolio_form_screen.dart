import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../core/investment_calculator.dart';
import '../../domain/models/investment.dart';

class PortfolioFormScreen extends ConsumerStatefulWidget {
  const PortfolioFormScreen({super.key});
  @override
  ConsumerState<PortfolioFormScreen> createState() =>
      _PortfolioFormScreenState();
}

class _PortfolioFormScreenState extends ConsumerState<PortfolioFormScreen>
    with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _buyPriceCtrl = TextEditingController();
  final _currentPriceCtrl = TextEditingController();
  final _unitsCtrl = TextEditingController();
  final _folioCtrl = TextEditingController();
  final _sipAmountCtrl = TextEditingController();
  final _interestCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _buyPriceFocus = FocusNode();
  final _currentPriceFocus = FocusNode();
  final _unitsFocus = FocusNode();
  final _folioFocus = FocusNode();
  final _sipAmountFocus = FocusNode();
  final _interestFocus = FocusNode();
  final _searchFocus = FocusNode();

  final _pageController = PageController(initialPage: 0);
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  AssetType _type = AssetType.stocks;
  DateTime _date = DateTime.now();
  DateTime? _maturityDate;
  bool _isSip = false;
  String _sipFreq = 'monthly';
  int _sipDay = 1;
  int _currentStep = 0;
  bool _saved = false;

  final Set<String> _touched = {};
  final Map<String, String> _errors = {};

  static const _mockPrices = {
    'hdfc bank': 167250,
    'reliance industries': 295400,
    'tcs': 412300,
    'infosys': 189500,
    'icici bank': 112800,
    'sbi': 78450,
    'bajaj finance': 89400,
    'axis bank': 115600,
    'hdfc': 163400,
    'itc': 42950,
    'sbi magnum midcap': 217500,
    'axis bluechip fund': 55800,
    'hdfc top 100 fund': 47500,
    'icici prudential value': 62300,
    'kotak emerging equity': 98500,
    'digital gold': 715050,
    'gold etf': 625000,
    'sovereign gold bond': 628000,
    'ppf': 100000,
    'nps tier 1': 50000,
    'nps tier 2': 35000,
    'bitcoin': 480000000,
    'ethereum': 32000000,
    'solana': 1450000,
    'polkadot': 72500,
    'cardano': 68000,
    'sbi fixed deposit': 100000,
    'hdfc fixed deposit': 100000,
    'icici fixed deposit': 100000,
    '8% tax free bonds 2030': 100000,
    '7.5% govt bond 2032': 100000,
    'nifty bees': 254500,
    'bank bees': 51200,
    'junior bees': 645000,
  };

  List<String> get _suggestions {
    final q = _searchCtrl.text.toLowerCase().trim();
    if (q.isEmpty) return [];
    return _mockPrices.keys
        .where((k) => k.contains(q))
        .take(5)
        .map((k) => k.split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '))
        .toList()
      ..sort();
  }

  int? _lookupPrice(String name) {
    final key = name.toLowerCase().trim();
    for (final entry in _mockPrices.entries) {
      if (entry.key == key) return entry.value;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
    _nameCtrl.addListener(_validateOnChange);
    _buyPriceCtrl.addListener(_validateOnChange);
    _currentPriceCtrl.addListener(_validateOnChange);
    _unitsCtrl.addListener(_validateOnChange);
    _sipAmountCtrl.addListener(_validateOnChange);
    _interestCtrl.addListener(_validateOnChange);
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _buyPriceCtrl.dispose();
    _currentPriceCtrl.dispose();
    _unitsCtrl.dispose();
    _folioCtrl.dispose();
    _sipAmountCtrl.dispose();
    _interestCtrl.dispose();
    _searchCtrl.dispose();
    _nameFocus.dispose();
    _buyPriceFocus.dispose();
    _currentPriceFocus.dispose();
    _unitsFocus.dispose();
    _folioFocus.dispose();
    _sipAmountFocus.dispose();
    _interestFocus.dispose();
    _searchFocus.dispose();
    _pageController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
    final price = _lookupPrice(_searchCtrl.text);
    if (price != null) {
      _currentPriceCtrl.text = Money.toEditString(price);
    }
  }

  void _validateOnChange() {
    setState(() => _validate());
  }

  String? _validateField(String field, String? value,
      {bool required = true, bool isNumber = false, bool positive = false}) {
    if (required && (value == null || value.trim().isEmpty)) {
      return 'Required';
    }
    if (isNumber && value != null && value.isNotEmpty) {
      final parsed = double.tryParse(value);
      if (parsed == null) return 'Invalid number';
      if (positive && parsed <= 0) return 'Must be > 0';
    }
    return null;
  }

  bool _validate() {
    _errors.clear();
    final nameErr = _validateField('name', _nameCtrl.text);
    if (nameErr != null) _errors['name'] = nameErr;

    final showUnits = _type != AssetType.fd && _type != AssetType.ppf;
    if (showUnits) {
      final unitsErr = _validateField('units', _unitsCtrl.text,
          isNumber: true, positive: true);
      if (unitsErr != null) _errors['units'] = unitsErr;
    }

    final buyErr = _validateField('buyPrice', _buyPriceCtrl.text,
        isNumber: true, positive: true);
    if (buyErr != null) _errors['buyPrice'] = buyErr;

    final cpErr = _validateField('currentPrice', _currentPriceCtrl.text,
        isNumber: true, positive: true);
    if (cpErr != null) _errors['currentPrice'] = cpErr;

    if (_type == AssetType.fd || _type == AssetType.ppf) {
      final irErr = _validateField('interest', _interestCtrl.text,
          isNumber: true, positive: true);
      if (irErr != null) _errors['interest'] = irErr;
    }

    if (_isSip) {
      final sipErr = _validateField('sipAmount', _sipAmountCtrl.text,
          isNumber: true, positive: true);
      if (sipErr != null) _errors['sipAmount'] = sipErr;
    }

    return _errors.isEmpty;
  }

  bool _validateStep(int step) {
    _touched.addAll(['name', 'buyPrice', 'currentPrice', 'units', 'interest', 'sipAmount']);
    switch (step) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty;
      case 1:
        final ok = Money.parseToMinor(_buyPriceCtrl.text) != null &&
            Money.parseToMinor(_currentPriceCtrl.text) != null;
        if (_type != AssetType.fd && _type != AssetType.ppf) {
          final u = double.tryParse(_unitsCtrl.text);
          return ok && u != null && u > 0;
        }
        return ok;
      case 2:
        if (_type.hasMaturity && _maturityDate == null) return false;
        if (_type == AssetType.fd || _type == AssetType.ppf) {
          return double.tryParse(_interestCtrl.text) != null &&
              double.parse(_interestCtrl.text) > 0;
        }
        if (_isSip) {
          return Money.parseToMinor(_sipAmountCtrl.text) != null;
        }
        return true;
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (!_validateStep(_currentStep)) {
        _showError('Please fill required fields');
        return;
      }
      setState(() => _currentStep++);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      _animCtrl.forward(from: 0);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(_currentStep,
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      _animCtrl.forward(from: 0);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.expense,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Investment _buildInvestment() {
    final units = double.tryParse(_unitsCtrl.text) ?? 1;
    final buyPrice = Money.parseToMinor(_buyPriceCtrl.text) ?? 0;
    final currentPrice = Money.parseToMinor(_currentPriceCtrl.text) ?? buyPrice;

    return Investment(
      assetType: _type,
      name: _nameCtrl.text.trim(),
      folioNumber: _folioCtrl.text.isNotEmpty ? _folioCtrl.text : null,
      units: units,
      buyPricePerUnit: buyPrice,
      currentPricePerUnit: currentPrice,
      investedDate: _date,
      maturityDate: _type.hasMaturity ? _maturityDate : null,
      interestRate: _interestCtrl.text.isNotEmpty
          ? double.tryParse(_interestCtrl.text)
          : null,
      isSip: _isSip,
      sipAmount: Money.parseToMinor(_sipAmountCtrl.text),
      sipFrequency: _isSip ? _sipFreq : null,
      sipStartDate: _isSip ? _date : null,
      lastUpdatedAt: DateTime.now(),
    );
  }

  void _submit({bool addAnother = false}) {
    if (!_validate()) {
      _showError('Fix the highlighted fields');
      return;
    }
    final inv = _buildInvestment();
    ref.read(investmentControllerProvider.notifier).addInvestment(inv);
    setState(() => _saved = true);
    if (addAnother) {
      _resetForm();
    } else {
      Navigator.of(context).pop(true);
    }
  }

  void _resetForm() {
    setState(() {
      _nameCtrl.clear();
      _buyPriceCtrl.clear();
      _currentPriceCtrl.clear();
      _unitsCtrl.clear();
      _folioCtrl.clear();
      _sipAmountCtrl.clear();
      _interestCtrl.clear();
      _searchCtrl.clear();
      _type = AssetType.stocks;
      _date = DateTime.now();
      _maturityDate = null;
      _isSip = false;
      _sipFreq = 'monthly';
      _sipDay = 1;
      _currentStep = 0;
      _touched.clear();
      _errors.clear();
      _saved = false;
    });
    _pageController.jumpToPage(0);
    _animCtrl.forward(from: 0);
  }

  bool get _showUnits =>
      _type != AssetType.fd && _type != AssetType.ppf;
  bool get _showMaturity => _type.hasMaturity;
  bool get _showInterest =>
      _type == AssetType.fd || _type == AssetType.ppf;
  bool get _showSipToggle => _type == AssetType.sip;

  int? get _previewMaturityValue {
    if (!_showMaturity || _maturityDate == null) return null;
    final buyPrice = Money.parseToMinor(_buyPriceCtrl.text);
    final rate = double.tryParse(_interestCtrl.text);
    if (buyPrice == null || rate == null || rate <= 0) return null;
    final principal = _showUnits
        ? buyPrice * (double.tryParse(_unitsCtrl.text) ?? 1)
        : buyPrice;
    return InvestmentCalculator.expectedMaturityValue(
      principal.round(),
      rate,
      _date,
      _maturityDate!,
      type: AssetInterestType.compoundedAnnually,
    );
  }

  double? get _previewXirr {
    final buyPrice = Money.parseToMinor(_buyPriceCtrl.text);
    final currentPrice = Money.parseToMinor(_currentPriceCtrl.text);
    if (buyPrice == null || currentPrice == null) return null;
    final principal = _showUnits
        ? buyPrice * (double.tryParse(_unitsCtrl.text) ?? 1)
        : buyPrice;
    final value = _showUnits
        ? currentPrice * (double.tryParse(_unitsCtrl.text) ?? 1)
        : currentPrice;
    if (principal <= 0) return null;
    return InvestmentCalculator.xirrForInvestment(
      principal.round(),
      value.round(),
      _date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Investment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(_saved),
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(),
                _buildPricingStep(),
                _buildDetailsStep(),
                _buildReviewStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Basic Info', 'Pricing', 'Details', 'Review'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (i < _currentStep) {
                  setState(() => _currentStep = i);
                  _pageController.animateToPage(i,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive || isDone
                          ? AppTheme.primary
                          : AppTheme.border,
                      width: isActive ? 2.5 : 1.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppTheme.primary
                            : isActive
                                ? AppTheme.primary.withAlpha(30)
                                : Colors.transparent,
                        border: Border.all(
                          color: isActive || isDone
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          width: isActive ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                )),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(steps[i],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive || isDone
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onAssetTypeChanged(AssetType t) {
    setState(() {
      _type = t;
      _isSip = t == AssetType.sip;
      if (t != AssetType.sip) _isSip = false;
      if (t != AssetType.fd && t != AssetType.ppf) _interestCtrl.clear();
    });
  }

  Widget _buildBasicInfoStep() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What are you investing in?',
                style: AppTheme.sectionTitle),
            const SizedBox(height: 20),
            _buildAssetTypeGrid(),
            const SizedBox(height: 20),
            _buildField(
              controller: _nameCtrl,
              label: 'Instrument Name',
              hint: 'e.g. HDFC Bank, SBI Magnum',
              focusNode: _nameFocus,
              error: _errors['name'],
              touched: _touched.contains('name'),
              onChanged: (v) {
                _onSearchChanged();
                setState(() {});
              },
            ),
            const SizedBox(height: 8),
            if (_suggestions.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: _suggestions.map((s) {
                    return ListTile(
                      dense: true,
                      title: Text(s,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textPrimary)),
                      trailing: _lookupPrice(s) != null
                          ? Text(Money.format(_lookupPrice(s)!),
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.primary))
                          : null,
                      onTap: () {
                        _nameCtrl.text = s;
                        _nameCtrl.selection = TextSelection.fromPosition(
                            TextPosition(offset: s.length));
                        _searchCtrl.text = s;
                        _onSearchChanged();
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
            _buildField(
              controller: _folioCtrl,
              label: 'Folio / Account No.',
              hint: 'Optional',
              focusNode: _folioFocus,
              error: _errors['folio'],
              touched: _touched.contains('folio'),
            ),
            const SizedBox(height: 24),
            _buildDateField(
              icon: Icons.calendar_today,
              label: 'Invested Date',
              date: _date,
              onPick: (d) => setState(() => _date = d),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _nextStep,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next – Pricing'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTypeGrid() {
    const assets = [
      (AssetType.stocks, Icons.trending_up, 'Stocks'),
      (AssetType.mutualFund, Icons.account_balance, 'Mutual Fund'),
      (AssetType.sip, Icons.repeat, 'SIP'),
      (AssetType.gold, Icons.monetization_on, 'Gold'),
      (AssetType.fd, Icons.lock, 'FD'),
      (AssetType.ppf, Icons.savings, 'PPF'),
      (AssetType.nps, Icons.verified_user, 'NPS'),
      (AssetType.crypto, Icons.currency_bitcoin, 'Crypto'),
      (AssetType.bonds, Icons.article, 'Bonds'),
      (AssetType.other, Icons.more_horiz, 'Other'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Asset Type',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 0.85,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: assets.length,
          itemBuilder: (ctx, i) {
            final (type, icon, label) = assets[i];
            final sel = _type == type;
            return GestureDetector(
              onTap: () => _onAssetTypeChanged(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.accent.withAlpha(25)
                      : AppTheme.cardGlass,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? AppTheme.accent : AppTheme.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon,
                        size: 22,
                        color: sel
                            ? AppTheme.accent
                            : AppTheme.textSecondary),
                    const SizedBox(height: 4),
                    Text(label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel
                              ? AppTheme.accent
                              : AppTheme.textSecondary,
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingStep() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pricing Details',
                style: AppTheme.sectionTitle),
            const SizedBox(height: 8),
            Text('Enter buy and current price',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            _buildField(
              controller: _searchCtrl,
              label: 'Search instrument for current price',
              hint: 'e.g. hdfc bank, tcs, sbi magnum',
              focusNode: _searchFocus,
              error: _errors['search'],
              touched: _touched.contains('search'),
              suffix: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearchChanged();
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            if (_showUnits) ...[
              _buildField(
                controller: _unitsCtrl,
                label: 'Units / Quantity',
                hint: 'e.g. 10',
                keyboardType: TextInputType.number,
                focusNode: _unitsFocus,
                error: _errors['units'],
                touched: _touched.contains('units'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _buyPriceCtrl,
                    label: 'Buy Price (₹)',
                    hint: '0.00',
                    prefixText: '₹ ',
                    keyboardType: TextInputType.number,
                    focusNode: _buyPriceFocus,
                    error: _errors['buyPrice'],
                    touched: _touched.contains('buyPrice'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _currentPriceCtrl,
                    label: 'Current Price (₹)',
                    hint: '0.00',
                    prefixText: '₹ ',
                    keyboardType: TextInputType.number,
                    focusNode: _currentPriceFocus,
                    error: _errors['currentPrice'],
                    touched: _touched.contains('currentPrice'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMiniPreview(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prevStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _nextStep,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next – Details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPreview() {
    final buyPrice = Money.parseToMinor(_buyPriceCtrl.text);
    final currentPrice = Money.parseToMinor(_currentPriceCtrl.text);
    if (buyPrice == null && currentPrice == null) return const SizedBox.shrink();

    final principal = _showUnits
        ? (buyPrice ?? 0) * (double.tryParse(_unitsCtrl.text) ?? 1)
        : (buyPrice ?? 0);
    final value = _showUnits
        ? (currentPrice ?? buyPrice ?? 0) * (double.tryParse(_unitsCtrl.text) ?? 1)
        : (currentPrice ?? buyPrice ?? 0);
    final gain = value - principal;
    final gainPct = principal > 0 ? (gain / principal) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withAlpha(40)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Estimated Value',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(Money.format(value.round()),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: gain >= 0
                  ? AppTheme.income.withAlpha(20)
                  : AppTheme.expense.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${gain >= 0 ? '+' : ''}${Money.format(gain.round())} (${gainPct.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: gain >= 0 ? AppTheme.income : AppTheme.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Additional Details',
                style: AppTheme.sectionTitle),
            const SizedBox(height: 8),
            Text('Optional info for better tracking',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            if (_showInterest) ...[
              _buildField(
                controller: _interestCtrl,
                label: 'Interest Rate (% p.a.)',
                hint: 'e.g. 7.5',
                keyboardType: TextInputType.number,
                prefixText: '% ',
                focusNode: _interestFocus,
                error: _errors['interest'],
                touched: _touched.contains('interest'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
            ],
            if (_showMaturity) ...[
              _buildDateField(
                icon: Icons.event,
                label: 'Maturity Date',
                date: _maturityDate,
                onPick: (d) => setState(() => _maturityDate = d),
                firstDate: _date,
                lastDate: DateTime(2100),
                placeholder: 'Set maturity date',
              ),
              const SizedBox(height: 16),
            ],
            if (_showSipToggle) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.repeat,
                            size: 18, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text('SIP Details',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textPrimary)),
                        const Spacer(),
                        Switch(
                          value: _isSip,
                          onChanged: (v) =>
                              setState(() => _isSip = v),
                          activeColor: AppTheme.primary,
                        ),
                      ],
                    ),
                    if (_isSip) ...[
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _sipAmountCtrl,
                        label: 'SIP Amount (₹)',
                        hint: 'e.g. 5000',
                        prefixText: '₹ ',
                        keyboardType: TextInputType.number,
                        focusNode: _sipAmountFocus,
                        error: _errors['sipAmount'],
                        touched: _touched.contains('sipAmount'),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      Text('SIP Frequency',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['monthly', 'quarterly', 'yearly']
                            .map((f) {
                          final sel = _sipFreq == f;
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _sipFreq = f),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppTheme.primary.withAlpha(25)
                                        : AppTheme.cardGlass,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: sel
                                          ? AppTheme.primary
                                          : AppTheme.border,
                                    ),
                                  ),
                                  child: Text(
                                    f[0].toUpperCase() + f.substring(1),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: sel
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: sel
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('SIP Day of Month',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 28,
                          itemBuilder: (ctx, i) {
                            final day = i + 1;
                            final sel = _sipDay == day;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _sipDay = day),
                              child: Container(
                                width: 40,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.primary.withAlpha(25)
                                      : AppTheme.cardGlass,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.border,
                                  ),
                                ),
                                child: Center(
                                  child: Text('$day',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: sel
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                      )),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _prevStep,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _nextStep,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Review'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final buyPrice = Money.parseToMinor(_buyPriceCtrl.text);
    final currentPrice = Money.parseToMinor(_currentPriceCtrl.text);
    final principal = _showUnits
        ? (buyPrice ?? 0) * (double.tryParse(_unitsCtrl.text) ?? 1)
        : (buyPrice ?? 0);
    final value = _showUnits
        ? (currentPrice ?? buyPrice ?? 0) * (double.tryParse(_unitsCtrl.text) ?? 1)
        : (currentPrice ?? buyPrice ?? 0);
    final gain = value - principal;
    final gainPct = principal > 0 ? (gain / principal) * 100 : 0.0;
    final xirr = _previewXirr;
    final mv = _previewMaturityValue;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Review & Confirm',
                style: AppTheme.sectionTitle),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withAlpha(20),
                    AppTheme.accent.withAlpha(15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withAlpha(30)),
              ),
              child: Column(
                children: [
                  Text('Portfolio Preview',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _previewItem('Invested', Money.format(principal.round()),
                          AppTheme.textPrimary),
                      _previewItem('Current', Money.format(value.round()),
                          AppTheme.textPrimary),
                      _previewItem(
                        'Gain/Loss',
                        '${gain >= 0 ? '+' : ''}${Money.format(gain.round())}',
                        gain >= 0 ? AppTheme.income : AppTheme.expense,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _previewItem(
                          'Returns', '${gainPct.toStringAsFixed(1)}%',
                          gain >= 0 ? AppTheme.income : AppTheme.expense),
                      _previewItem(
                        'XIRR',
                        xirr != null ? '${xirr.toStringAsFixed(2)}%' : '--',
                        AppTheme.accent,
                      ),
                      _previewItem(
                        'Maturity',
                        mv != null ? Money.format(mv) : '--',
                        AppTheme.warning,
                      ),
                    ],
                  ),
                  if (mv != null && principal > 0) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (principal / mv).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          mv > principal ? AppTheme.income : AppTheme.expense),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${((mv - principal) / principal * 100).toStringAsFixed(1)}% projected growth',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSummaryRow('Asset Type', _type.label, Icons.category),
            const Divider(color: AppTheme.border),
            _buildSummaryRow('Name', _nameCtrl.text.trim(), Icons.text_fields),
            const Divider(color: AppTheme.border),
            if (_showUnits) ...[
              _buildSummaryRow('Units', _unitsCtrl.text, Icons.numbers),
              const Divider(color: AppTheme.border),
            ],
            _buildSummaryRow(
                'Buy Price', Money.format(buyPrice ?? 0), Icons.shopping_cart),
            const Divider(color: AppTheme.border),
            _buildSummaryRow('Current Price',
                Money.format(currentPrice ?? buyPrice ?? 0), Icons.trending_up),
            const Divider(color: AppTheme.border),
            _buildSummaryRow(
                'Invested Date',
                '${_date.day}/${_date.month}/${_date.year}',
                Icons.calendar_today),
            if (_showMaturity && _maturityDate != null) ...[
              const Divider(color: AppTheme.border),
              _buildSummaryRow(
                  'Maturity Date',
                  '${_maturityDate!.day}/${_maturityDate!.month}/${_maturityDate!.year}',
                  Icons.event),
            ],
            if (_showInterest && _interestCtrl.text.isNotEmpty) ...[
              const Divider(color: AppTheme.border),
              _buildSummaryRow(
                  'Interest Rate', '${_interestCtrl.text}%', Icons.percent),
            ],
            if (_isSip) ...[
              const Divider(color: AppTheme.border),
              _buildSummaryRow('SIP Amount',
                  Money.format(Money.parseToMinor(_sipAmountCtrl.text) ?? 0),
                  Icons.repeat),
              const Divider(color: AppTheme.border),
              _buildSummaryRow('SIP Frequency', _sipFreq, Icons.schedule),
              const Divider(color: AppTheme.border),
              _buildSummaryRow('SIP Day', 'Day $_sipDay', Icons.calendar_month),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _submit(),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Add Investment'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _submit(addAnother: true),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text('Save & Add Another'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                minimumSize: const Size(double.infinity, 54),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _prevStep,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Details'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _previewItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required IconData icon,
    required String label,
    required DateTime? date,
    required ValueChanged<DateTime> onPick,
    required DateTime firstDate,
    required DateTime lastDate,
    String? placeholder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: date ?? DateTime.now(),
                      firstDate: firstDate,
                      lastDate: lastDate,
                    );
                    if (d != null) onPick(d);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : (placeholder ?? 'Select date'),
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    String? prefixText,
    Widget? suffix,
    String? error,
    bool touched = false,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = touched && error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: hasError ? AppTheme.expense : AppTheme.textPrimary)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: hasError
                ? AppTheme.expense.withAlpha(10)
                : AppTheme.bg.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppTheme.expense : AppTheme.border,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: AppTheme.textSecondary.withAlpha(120)),
              prefixText: prefixText,
              prefixStyle: const TextStyle(color: AppTheme.textPrimary),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error!,
                style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.expense)),
          ),
      ],
    );
  }
}
