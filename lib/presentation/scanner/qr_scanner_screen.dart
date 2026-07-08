import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/category_suggestions.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../core/upi_parser.dart';
import '../expense/expense_form_screen.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final _controller = MobileScannerController(torchEnabled: false);
  bool _torchOn = false;
  bool _cameraReady = false;

  final _manualController = TextEditingController();
  final _amountController = TextEditingController();
  String? _detectedUpiRaw;
  UpiData? _detectedUpi;
  bool _showDetailCard = false;
  String? _selectedCategory;

  late AnimationController _scanLineController;
  late Animation<Offset> _scanLineAnimation;

  List<Map<String, String>> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.8),
    ).animate(CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.easeInOut,
    ));
    _loadScanHistory();
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _manualController.dispose();
    _amountController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('scan_history');
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      if (mounted) {
        setState(() {
          _scanHistory = list
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        });
      }
    }
  }

  Future<void> _saveScanHistory(String raw, UpiData? upi) async {
    final entry = <String, String>{
      'raw': raw,
      'label': upi?.name ?? upi?.vpa ?? raw,
    };
    if (upi?.amountMinor != null) {
      entry['amount'] = Money.toEditString(upi!.amountMinor!);
    }
    _scanHistory.insert(0, entry);
    if (_scanHistory.length > 10) {
      _scanHistory = _scanHistory.sublist(0, 10);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scan_history', jsonEncode(_scanHistory));
  }

  void _onDetect(BarcodeCapture capture) {
    if (_showDetailCard) return;
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _controller.stop();
    _processScan(raw);
  }

  void _processScan(String raw) {
    final upi = UpiParser.parse(raw);
    if (upi != null) {
      _detectedUpi = upi;
      _detectedUpiRaw = raw;
      final suggested = CategorySuggestor.suggest(upi.name);
      setState(() {
        _selectedCategory = suggested.name;
        _showDetailCard = true;
        _manualController.text = upi.name ?? upi.vpa ?? '';
        _amountController.text = upi.amountMinor != null
            ? Money.toEditString(upi.amountMinor!)
            : '';
      });
      _saveScanHistory(raw, upi);
    } else {
      _detectedUpi = null;
      _detectedUpiRaw = raw;
      setState(() {
        _selectedCategory = CategorySuggestor.suggest(raw).name;
        _showDetailCard = true;
        _manualController.text = raw;
        _amountController.text = '';
      });
      _saveScanHistory(raw, null);
    }
  }

  void _handleManualSubmit() {
    final text = _manualController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a UPI ID or description')),
      );
      return;
    }
    final upi = UpiParser.parse(text);
    if (upi != null) {
      _detectedUpi = upi;
      _detectedUpiRaw = text;
      final suggested = CategorySuggestor.suggest(upi.name);
      setState(() {
        _selectedCategory = suggested.name;
        _showDetailCard = true;
        _amountController.text = upi.amountMinor != null
            ? Money.toEditString(upi.amountMinor!)
            : _amountController.text;
      });
    } else {
      _detectedUpi = null;
      _detectedUpiRaw = text;
      setState(() {
        _selectedCategory = CategorySuggestor.suggest(text).name;
        _showDetailCard = true;
      });
    }
  }

  void _confirmExpense() {
    final notifier = ref.read(expenseFormControllerProvider.notifier);
    notifier.reset();
    final notes = _manualController.text.trim();
    if (notes.isNotEmpty) notifier.setNotes(notes);
    final amountStr = _amountController.text.trim();
    if (amountStr.isNotEmpty) {
      final minor = Money.parseToMinor(amountStr);
      if (minor != null) notifier.setAmount(Money.toEditString(minor));
    }
    if (_selectedCategory != null) {
      notifier.setCategory(
        Category.values.firstWhere(
          (c) => c.name == _selectedCategory,
          orElse: () => Category.other,
        ),
      );
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ExpenseFormScreen(),
      ),
    );
  }

  void _rescan() {
    setState(() {
      _showDetailCard = false;
      _detectedUpi = null;
      _detectedUpiRaw = null;
    });
    _controller.start();
  }

  void _showHowToScan() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.primary, size: 24),
            SizedBox(width: 10),
            Text('How to Scan',
                style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuideStep(
                icon: Icons.qr_code_scanner,
                step: '1',
                text: 'Point your camera at any UPI QR code from Paytm, '
                    'Google Pay, PhonePe, or any UPI app.',
              ),
              SizedBox(height: 14),
              _GuideStep(
                icon: Icons.center_focus_strong,
                step: '2',
                text: 'Hold steady until the code is detected. '
                    'A green scan line will cross the frame.',
              ),
              SizedBox(height: 14),
              _GuideStep(
                icon: Icons.edit_note,
                step: '3',
                text: 'Review the detected merchant name and amount. '
                    'Edit if needed before saving.',
              ),
              SizedBox(height: 14),
              _GuideStep(
                icon: Icons.category,
                step: '4',
                text: 'Pick a category or use the auto-suggested one. '
                    'Then tap Confirm to log the expense.',
              ),
              SizedBox(height: 14),
              _GuideStep(
                icon: Icons.text_fields,
                step: '5',
                text: 'No QR? Type a UPI ID (e.g. merchant@upi) manually '
                    'in the text field below the scanner.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got it',
                style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Category',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: Category.values.map((cat) {
                final selected = _selectedCategory == cat.name;
                return ChoiceChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = cat.name);
                    Navigator.of(ctx).pop();
                  },
                  selectedColor: AppTheme.primary.withAlpha(50),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.border,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onHistoryTap(Map<String, String> entry) {
    final raw = entry['raw'] ?? '';
    if (raw.isEmpty) return;
    _processScan(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Scan QR',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _showHowToScan,
          ),
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() => _torchOn = !_torchOn);
              _controller.toggleTorch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                ),
                if (!_cameraReady)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                            color: AppTheme.primary),
                        SizedBox(height: 12),
                        Text('Starting camera\u2026',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primary.withAlpha(180),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _scanLineAnimation,
                            builder: (context, child) {
                              return FractionalTranslation(
                                translation: _scanLineAnimation.value,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primary.withAlpha(0),
                                        AppTheme.primary,
                                        AppTheme.primary,
                                        AppTheme.primary.withAlpha(0),
                                      ],
                                      stops: const [
                                        0.0,
                                        0.3,
                                        0.7,
                                        1.0,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withAlpha(80),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            child: _cornerPainter(
                                AppTheme.primary, -1, -1),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: _cornerPainter(
                                AppTheme.primary, 1, -1),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: _cornerPainter(
                                AppTheme.primary, -1, 1),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: _cornerPainter(
                                AppTheme.primary, 1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_showDetailCard)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildDetailCard(),
                  ),
              ],
            ),
          ),
          if (!_showDetailCard) _buildBottomPanel(),
          if (!_showDetailCard && _scanHistory.isNotEmpty)
            _buildHistoryBar(),
        ],
      ),
    );
  }

  Widget _cornerPainter(Color color, double dx, double dy) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: dy < 0
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          bottom: dy > 0
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          left: dx < 0
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
          right: dx > 0
              ? BorderSide(color: color, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    final upi = _detectedUpi;
    final categories = Category.values;
    final suggestedName = _selectedCategory ?? 'other';

    List<Category> keywordCategories = [];
    if (upi != null && upi.name != null) {
      final sug = CategorySuggestor.suggest(upi.name);
      keywordCategories = categories
          .where((c) => c.name == sug.name)
          .toList();
    } else if (_detectedUpiRaw != null) {
      final sug = CategorySuggestor.suggest(_detectedUpiRaw);
      keywordCategories = categories
          .where((c) => c.name == sug.name)
          .toList();
    }

    return AnimatedSlide(
      duration: const Duration(milliseconds: 350),
      offset: _showDetailCard ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 350),
        opacity: _showDetailCard ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(100),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payments_outlined,
                        color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upi?.name ?? upi?.vpa ?? 'Merchant',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (upi?.vpa != null)
                          Text(
                            upi!.vpa!,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (upi?.amountMinor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        Money.format(upi!.amountMinor!),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _manualController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Payee / Description',
                  prefixIcon: Icon(Icons.person_outline,
                      color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon: Icon(Icons.currency_rupee,
                      color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 14),
              Text('Suggested Categories',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  )),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...keywordCategories.map((cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryChip(
                            cat.label,
                            cat.name == suggestedName,
                            () {
                              setState(
                                  () => _selectedCategory = cat.name);
                            },
                          ),
                        )),
                    _buildCategoryChip(
                      _selectedCategory != null &&
                              keywordCategories
                                  .map((c) => c.name)
                                  .contains(_selectedCategory)
                          ? 'Change'
                          : (_selectedCategory ?? 'Other'),
                      false,
                      _showCategoryPicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rescan,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Rescan'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(
                            color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _confirmExpense,
                      icon: const Icon(Icons.check_circle_outline,
                          size: 18),
                      label: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
      String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withAlpha(30)
              : AppTheme.bg.withAlpha(80),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _manualController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Or type UPI ID / text\u2026',
                    hintStyle: TextStyle(
                        color: Colors.white38, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white.withAlpha(15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    prefixIcon: const Icon(Icons.text_fields,
                        color: Colors.white38, size: 20),
                  ),
                  onSubmitted: (_) => _handleManualSubmit(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _handleManualSubmit,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        color: Colors.white54, size: 14),
                    SizedBox(width: 6),
                    Text('Point camera at QR code',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.only(left: 16, top: 10, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.history, color: Colors.white38, size: 14),
              const SizedBox(width: 6),
              const Text('Recent Scans',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const Spacer(),
              if (_scanHistory.length > 1)
                GestureDetector(
                  onTap: () {
                    setState(() => _scanHistory.clear());
                    SharedPreferences.getInstance().then(
                        (p) => p.remove('scan_history'));
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.delete_sweep,
                        color: Colors.white24, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _scanHistory.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final entry = _scanHistory[index];
                final label = entry['label'] ?? 'Scan';
                final amount = entry['amount'];
                return GestureDetector(
                  onTap: () => _onHistoryTap(entry),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.border, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay,
                            size: 12,
                            color: AppTheme.primary.withAlpha(180)),
                        const SizedBox(width: 6),
                        Text(
                          label.length > 16
                              ? '${label.substring(0, 16)}\u2026'
                              : label,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        if (amount != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '\u20B9$amount',
                            style: TextStyle(
                              color: AppTheme.primary.withAlpha(200),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
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

class _GuideStep extends StatelessWidget {
  final IconData icon;
  final String step;
  final String text;

  const _GuideStep({
    required this.icon,
    required this.step,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step $step',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(text,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
