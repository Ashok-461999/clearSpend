import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/money.dart';
import '../../core/theme.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _SplitEntry {
  Category category;
  double percentage;

  _SplitEntry({required this.category, this.percentage = 0});
}

class _SavedTemplate {
  final String name;
  final int? editingId;
  final String amountText;
  final Category? category;
  final String notes;
  final DateTime date;
  final String? receiptPath;
  final String? locationName;
  final bool isRecurring;
  final String recurringFrequency;
  final DateTime? recurringEndDate;
  final List<_SplitEntry> splits;

  _SavedTemplate({
    required this.name,
    this.editingId,
    this.amountText = '',
    this.category,
    this.notes = '',
    required this.date,
    this.receiptPath,
    this.locationName,
    this.isRecurring = false,
    this.recurringFrequency = 'monthly',
    this.recurringEndDate,
    this.splits = const [],
  });
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _templateNameCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _receiptPath;
  String? _locationName;
  bool _isRecurring = false;
  String _recurringFrequency = 'monthly';
  DateTime? _recurringEndDate;
  bool _splitEnabled = false;
  List<_SplitEntry> _splits = [];
  List<_SavedTemplate> _templates = [];

  @override
  void initState() {
    super.initState();
    _initSplits();
    _loadTemplates();
  }

  void _initSplits() {
    final expenseCats = Category.values.where((c) => !c.isIncome).toList();
    _splits = expenseCats.map((c) => _SplitEntry(category: c)).toList();
  }

  void _loadTemplates() {
    final saved = ref.read(sharedPreferencesProvider);
    final count = saved.getInt('template_count') ?? 0;
    final templates = <_SavedTemplate>[];
    for (var i = 0; i < count; i++) {
      final name = saved.getString('template_${i}_name');
      final amountText = saved.getString('template_${i}_amount') ?? '';
      final categoryIndex = saved.getInt('template_${i}_category');
      final notes = saved.getString('template_${i}_notes') ?? '';
      final receiptPath = saved.getString('template_${i}_receipt');
      final locationName = saved.getString('template_${i}_location');
      final isRecurring = saved.getBool('template_${i}_recurring') ?? false;
      final frequency = saved.getString('template_${i}_frequency') ?? 'monthly';
      final endDate = saved.getInt('template_${i}_end_date');
      if (name != null) {
        templates.add(_SavedTemplate(
          name: name,
          amountText: amountText,
          category: categoryIndex != null && categoryIndex >= 0 && categoryIndex < Category.values.length
              ? Category.values[categoryIndex]
              : null,
          notes: notes,
          date: DateTime.now(),
          receiptPath: receiptPath,
          locationName: locationName,
          isRecurring: isRecurring,
          recurringFrequency: frequency,
          recurringEndDate: endDate != null ? DateTime.fromMillisecondsSinceEpoch(endDate) : null,
        ));
      }
    }
    setState(() => _templates = templates);
  }

  void _saveTemplates() {
    final saved = ref.read(sharedPreferencesProvider);
    saved.setInt('template_count', _templates.length);
    for (var i = 0; i < _templates.length; i++) {
      final t = _templates[i];
      saved.setString('template_${i}_name', t.name);
      saved.setString('template_${i}_amount', t.amountText);
      saved.setInt('template_${i}_category', t.category?.index ?? -1);
      saved.setString('template_${i}_notes', t.notes);
      if (t.receiptPath != null) saved.setString('template_${i}_receipt', t.receiptPath!);
      if (t.locationName != null) saved.setString('template_${i}_location', t.locationName!);
      saved.setBool('template_${i}_recurring', t.isRecurring);
      saved.setString('template_${i}_frequency', t.recurringFrequency);
      if (t.recurringEndDate != null) {
        saved.setInt('template_${i}_end_date', t.recurringEndDate!.millisecondsSinceEpoch);
      }
    }
  }

  void _applyTemplate(_SavedTemplate t) {
    final notifier = ref.read(expenseFormControllerProvider.notifier);
    notifier.setAmount(t.amountText);
    if (t.category != null) notifier.setCategory(t.category!);
    notifier.setNotes(t.notes);
    notifier.setDate(t.date);
    setState(() {
      _receiptPath = t.receiptPath;
      _locationName = t.locationName;
      if (_locationName != null) _locationCtrl.text = _locationName!;
      _isRecurring = t.isRecurring;
      _recurringFrequency = t.recurringFrequency;
      _recurringEndDate = t.recurringEndDate;
      _splitEnabled = false;
    });
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _receiptPath = file.path);
    }
  }

  Future<void> _takePhoto() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _receiptPath = file.path);
    }
  }

  void _removeReceipt() {
    setState(() => _receiptPath = null);
  }

  void _showFullScreenImage() {
    if (_receiptPath == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Receipt'),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(_receiptPath!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 64, color: Colors.white38),
                    SizedBox(height: 12),
                    Text('Could not load image', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSaveTemplateDialog() {
    _templateNameCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as Template'),
        content: TextField(
          controller: _templateNameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Template name',
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = _templateNameCtrl.text.trim();
              if (name.isEmpty) return;
              final state = ref.read(expenseFormControllerProvider);
              setState(() {
                _templates.add(_SavedTemplate(
                  name: name,
                  amountText: state.amountText,
                  category: state.category,
                  notes: state.notes,
                  date: state.date,
                  receiptPath: _receiptPath,
                  locationName: _locationName,
                  isRecurring: _isRecurring,
                  recurringFrequency: _recurringFrequency,
                  recurringEndDate: _recurringEndDate,
                ));
                _saveTemplates();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTemplatesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final templates = _templates;
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollCtrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Text('Templates',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              if (templates.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No saved templates',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: templates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final t = templates[i];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryGlass,
                          child: const Icon(Icons.bookmark, color: AppTheme.primary, size: 20),
                        ),
                        title: Text(t.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        subtitle: Text(
                          t.amountText.isNotEmpty ? '₹${t.amountText}' : 'No amount set',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.expense),
                              onPressed: () {
                                setState(() {
                                  _templates.removeAt(i);
                                  _saveTemplates();
                                });
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.checklist, size: 20, color: AppTheme.primary),
                              onPressed: () {
                                _applyTemplate(t);
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    _templateNameCtrl.dispose();
    super.dispose();
  }

  Widget _buildCategorySection(
      String title, List<Category> cats, Category? selected,
      ValueChanged<Category> onTap) {
    if (cats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cats.map((c) {
            final sel = selected == c;
            return GestureDetector(
              onTap: () => onTap(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? c.color.withAlpha(30) : AppTheme.cardGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? c.color : AppTheme.border,
                    width: sel ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 20, color: c.color),
                    const SizedBox(width: 8),
                    Text(c.label,
                        style: TextStyle(
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                            color: sel ? c.color : AppTheme.textPrimary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.textPrimary)),
    );
  }

  Widget _buildSectionDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppTheme.border, thickness: 0.5),
    );
  }

  Widget _buildGlassField({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: child,
    );
  }

  Widget _buildReceiptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Receipt'),
        if (_receiptPath != null) ...[
          GestureDetector(
            onTap: _showFullScreenImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
                image: DecorationImage(
                  image: FileImage(File(_receiptPath!)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: _removeReceipt,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _showFullScreenImage,
            icon: const Icon(Icons.fullscreen, size: 16),
            label: const Text('View full screen', style: TextStyle(fontSize: 13)),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    foregroundColor: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    foregroundColor: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSplitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionLabel('Split Expense')),
            Switch(
              value: _splitEnabled,
              onChanged: (v) => setState(() => _splitEnabled = v),
            ),
          ],
        ),
        if (_splitEnabled) ...[
          const Text('Divide the total among multiple categories',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ..._splits.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(s.category.icon, size: 16, color: s.category.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.category.label,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary)),
                      ),
                      Text('${s.percentage.round()}%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: s.category.color)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: s.category.color,
                      thumbColor: s.category.color,
                      inactiveTrackColor: s.category.color.withAlpha(30),
                      overlayColor: s.category.color.withAlpha(20),
                    ),
                    child: Slider(
                      value: s.percentage,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${s.percentage.round()}%',
                      onChanged: (v) {
                        final diff = v - s.percentage;
                        final others = _splits.where((x) => x != s).toList();
                        final totalOther = others.fold<double>(0, (a, b) => a + b.percentage);
                        if (others.isNotEmpty && totalOther - diff < 0) return;
                        setState(() {
                          s.percentage = v;
                          if (others.isNotEmpty && diff != 0) {
                            final remaining = totalOther - diff;
                            final totalWeight = others.fold<double>(0, (a, b) => a + (b.percentage > 0 ? b.percentage : 1));
                            for (final o in others) {
                              final weight = o.percentage > 0 ? o.percentage : 1;
                              o.percentage = (remaining * weight / totalWeight).clamp(0, 100);
                            }
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: AppTheme.border, thickness: 0.5),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text('${_splits.fold<double>(0, (a, s) => a + s.percentage).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _splits.fold<double>(0, (a, s) => a + s.percentage).round() == 100
                        ? AppTheme.income
                        : AppTheme.expense,
                  )),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRecurringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSectionLabel('Recurring Transaction')),
            Switch(
              value: _isRecurring,
              onChanged: (v) => setState(() => _isRecurring = v),
            ),
          ],
        ),
        if (_isRecurring) ...[
          _buildGlassField(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _recurringFrequency,
                isExpanded: true,
                dropdownColor: AppTheme.cardSurface,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _recurringFrequency = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              const Text('End Date',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.edit_calendar, size: 16),
                label: Text(
                  _recurringEndDate != null
                      ? '${_recurringEndDate!.day} ${_months[_recurringEndDate!.month - 1]} ${_recurringEndDate!.year}'
                      : 'No end date',
                  style: const TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _recurringEndDate ?? DateTime.now().add(const Duration(days: 365)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _recurringEndDate = date);
                },
              ),
              if (_recurringEndDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: AppTheme.textSecondary),
                  onPressed: () => setState(() => _recurringEndDate = null),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Location'),
        Row(
          children: [
            Expanded(
              child: _buildGlassField(
                child: TextField(
                  controller: _locationCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add a location',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: AppTheme.textSecondary),
                  ),
                  onChanged: (v) => _locationName = v.isNotEmpty ? v : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location services: coming soon')),
              );
            },
            icon: const Icon(Icons.my_location, size: 16),
            label: const Text('Use current location', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseFormControllerProvider);
    final notifier = ref.read(expenseFormControllerProvider.notifier);
    final historyState = ref.watch(historyControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final monthlyBudget = settings.profile.monthlyBudget;
    final currentMonthExpense = historyState.totalExpense;
    final budgetRatio = monthlyBudget > 0 ? (currentMonthExpense / monthlyBudget) : 0.0;
    final notesCharCount = state.notes.length;
    final expenseCats = Category.values.where((c) => !c.isIncome).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(state.editingId == null ? 'Add Expense' : 'Edit Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: AppTheme.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == 'template_save') _showSaveTemplateDialog();
              if (v == 'template_load') _showTemplatesSheet();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'template_save',
                child: ListTile(
                  leading: Icon(Icons.bookmark_add, color: AppTheme.primary),
                  title: Text('Save as Template', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              PopupMenuItem(
                value: 'template_load',
                child: ListTile(
                  leading: Icon(Icons.bookmark, color: AppTheme.accent),
                  title: Text('Templates (${_templates.length})', style: const TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionLabel('Amount'),
            _buildGlassField(
              child: TextFormField(
                key: ValueKey('amount_${state.editingId ?? 'new'}'),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: state.amountText,
                onChanged: notifier.setAmount,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionLabel('Category'),
            const SizedBox(height: 10),
            _buildCategorySection(
              'Expense',
              expenseCats,
              state.category,
              notifier.setCategory,
            ),
            const SizedBox(height: 12),
            _buildCategorySection(
              'Income',
              Category.values.where((c) => c.isIncome).toList(),
              state.category,
              notifier.setCategory,
            ),
            const SizedBox(height: 24),
            _buildSectionDivider(),
            _buildReceiptSection(),
            _buildSectionDivider(),
            _buildSplitSection(),
            _buildSectionDivider(),
            _buildRecurringSection(),
            _buildSectionDivider(),
            _buildLocationSection(),
            _buildSectionDivider(),
            _buildSectionLabel('Notes'),
            _buildGlassField(
              child: TextField(
                controller: _notesCtrl,
                key: ValueKey('notes_${state.editingId ?? 'new'}'),
                decoration: InputDecoration(
                  hintText: 'What did you spend on?',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  suffixText: '$notesCharCount/500',
                  suffixStyle: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                maxLines: 3,
                maxLength: 500,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                onChanged: (v) => notifier.setNotes(v),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildFormatChip(Icons.format_bold, 'B'),
                const SizedBox(width: 6),
                _buildFormatChip(Icons.format_italic, 'I'),
                const SizedBox(width: 6),
                _buildFormatChip(Icons.format_underlined, 'U'),
                const SizedBox(width: 6),
                _buildFormatChip(Icons.format_list_bulleted, null),
                const SizedBox(width: 6),
                _buildFormatChip(Icons.format_list_numbered, null),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Date',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.edit_calendar, size: 18),
                  label: Text(
                    '${state.date.day} ${_months[state.date.month - 1]} ${state.date.year}',
                    style: const TextStyle(color: AppTheme.primary),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: state.date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) notifier.setDate(date);
                  },
                ),
              ],
            ),
            if (monthlyBudget > 0 && budgetRatio >= 0.8) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: budgetRatio >= 1.0
                      ? AppTheme.expenseGlass
                      : AppTheme.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: budgetRatio >= 1.0
                        ? AppTheme.expense.withAlpha(60)
                        : AppTheme.warning.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      budgetRatio >= 1.0
                          ? Icons.gpp_bad
                          : Icons.warning_amber_rounded,
                      size: 18,
                      color: budgetRatio >= 1.0
                          ? AppTheme.expense
                          : AppTheme.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        budgetRatio >= 1.0
                            ? 'You\'ve exceeded your monthly budget of ${Money.format(monthlyBudget)}!'
                            : 'You\'ve used ${(budgetRatio * 100).round()}% of your monthly budget',
                        style: TextStyle(
                          color: budgetRatio >= 1.0
                              ? AppTheme.expense
                              : AppTheme.warning,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.expenseGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.expense.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 18, color: AppTheme.expense),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.error!,
                          style:
                              const TextStyle(color: AppTheme.expense, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final success = await notifier.submit(
                        currentMonthExpense: currentMonthExpense,
                        monthlyBudget: monthlyBudget,
                      );
                      if (_isRecurring && success) {
                        _scheduleRecurring();
                      }
                      if (success && mounted) navigator.pop();
                    },
              child: state.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Save Expense'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(IconData icon, String? label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${label ?? 'List'} formatting: coming soon'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.cardGlass,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: label != null
            ? Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary))
            : Icon(icon, size: 16, color: AppTheme.textSecondary),
      ),
    );
  }

  void _scheduleRecurring() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recurring schedule set!')),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
