import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../core/money.dart';
import '../../core/category.dart';
import '../../domain/models/expense.dart';


class QuickExpenseSheet extends ConsumerStatefulWidget {
  const QuickExpenseSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickExpenseSheet(),
    );
  }

  @override
  ConsumerState<QuickExpenseSheet> createState() => _QuickExpenseSheetState();
}

class _QuickPreset {
  final int amountMinor;
  final Category category;
  const _QuickPreset({required this.amountMinor, required this.category});
}

class _QuickExpenseSheetState extends ConsumerState<QuickExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  Category? _selectedCategory;


  final List<_QuickPreset> _pinnedPresets = [];

  static const List<int> _quickAmounts = [50, 100, 200, 500, 1000, 2000, 5000];

  static const List<String> _emojis = [
    '😊', '🍕', '🚗', '🛒', '💡',
    '🏠', '💊', '🎬', '📚', '⚽',
    '☕', '👕', '🎮', '💻', '🐾',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(expenseFormControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountCtrl.text = amount.toString();
    _amountCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountCtrl.text.length),
    );
    ref.read(expenseFormControllerProvider.notifier).setAmount(amount.toString());
    setState(() {});
  }

  void _handleCustomTap() {
    _amountCtrl.clear();
    ref.read(expenseFormControllerProvider.notifier).setAmount('');
    setState(() {});
    Future.delayed(const Duration(milliseconds: 100), () {
      _amountFocus.requestFocus();
    });
  }

  void _savePreset() {
    final amount = Money.parseToMinor(_amountCtrl.text);
    if (amount == null || _selectedCategory == null) return;
    setState(() {
      _pinnedPresets.insert(
        0,
        _QuickPreset(amountMinor: amount, category: _selectedCategory!),
      );
      if (_pinnedPresets.length > 4) _pinnedPresets.removeLast();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset saved! Tap it from the top row to reuse.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _applyPreset(_QuickPreset preset) {
    _setQuickAmount(preset.amountMinor);
    setState(() {
      _selectedCategory = preset.category;

    });
    ref.read(expenseFormControllerProvider.notifier).setCategory(preset.category);
    _submit();
  }

  Future<void> _submit() async {
    final notifier = ref.read(expenseFormControllerProvider.notifier);
    final success = await notifier.submit();
    if (success && context.mounted) Navigator.of(context).pop();
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withAlpha(60),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Quick Expense',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: _amountCtrl,
        focusNode: _amountFocus,
        decoration: InputDecoration(
          labelText: 'Amount',
          prefixText: '₹ ',
          hintText: '0.00',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
        keyboardType: TextInputType.number,
        autofocus: true,
        onChanged: (v) {
          ref.read(expenseFormControllerProvider.notifier).setAmount(v);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildQuickAmountChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._quickAmounts.map((a) {
          final isSelected = _amountCtrl.text == a.toString();
          return GestureDetector(
            onTap: () => _setQuickAmount(a),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withAlpha(30)
                    : AppTheme.cardGlass,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Text(
                '₹$a',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        }),
        GestureDetector(
          onTap: _handleCustomTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardGlass,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 14, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAmounts(List<Expense> recentExpenses) {
    if (recentExpenses.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Recent amounts',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentExpenses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final e = recentExpenses[i];
              return GestureDetector(
                onTap: () {
                  _setQuickAmount(e.amountMinor);
                  setState(() => _selectedCategory = e.category);
                  ref
                      .read(expenseFormControllerProvider.notifier)
                      .setCategory(e.category);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: e.category.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: e.category.color.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.category.icon, size: 16, color: e.category.color),
                      const SizedBox(width: 6),
                      Text(
                        Money.format(e.amountMinor),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: e.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedPresets() {
    if (_pinnedPresets.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.push_pin, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              'Pinned presets',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _pinnedPresets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = _pinnedPresets[i];
              return GestureDetector(
                onTap: () => _applyPreset(p),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.category.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: p.category.color.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(p.category.icon, size: 16, color: p.category.color),
                      const SizedBox(width: 6),
                      Text(
                        '₹${p.amountMinor}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: p.category.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentCategoryIcons(List<Category> recentCats) {
    if (recentCats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Most used this month',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recentCats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final c = recentCats[i];
              final sel = _selectedCategory == c;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = c);
                  ref
                      .read(expenseFormControllerProvider.notifier)
                      .setCategory(c);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 66,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? c.color.withAlpha(30)
                        : AppTheme.cardGlass,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: sel ? c.color : AppTheme.border,
                      width: sel ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.icon, size: 28, color: c.color),
                      const SizedBox(height: 4),
                      Text(
                        c.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: sel ? c.color : AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategorySection(
    String title,
    List<Category> cats,
    Category? selected,
    ValueChanged<Category> onTap,
  ) {
    if (cats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cats.map((c) {
            final sel = selected == c;
            return GestureDetector(
              onTap: () => onTap(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? c.color.withAlpha(30) : AppTheme.cardGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel ? c.color : AppTheme.border,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 16, color: c.color),
                    const SizedBox(width: 6),
                    Text(
                      c.label,
                      style: TextStyle(
                        fontWeight:
                            sel ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                        color:
                            sel ? c.color : AppTheme.textPrimary,
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

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg.withAlpha(100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'What did you spend on?',
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            onChanged: (v) =>
                ref.read(expenseFormControllerProvider.notifier).setNotes(v),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _emojis.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4),
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  final pos = _notesCtrl.selection.baseOffset;
                  final text = _notesCtrl.text;
                  final insertPos = pos < 0 ? text.length : pos;
                  final newText =
                      '${text.substring(0, insertPos)}${_emojis[i]}${text.substring(insertPos)}';
                  _notesCtrl.text = newText;
                  _notesCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: insertPos + _emojis[i].length),
                  );
                  ref
                      .read(expenseFormControllerProvider.notifier)
                      .setNotes(newText);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.cardGlass,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _emojis[i],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final state = ref.watch(expenseFormControllerProvider);
    final historyState = ref.watch(historyControllerProvider);

    final allExpenses =
        historyState.days.expand((d) => d.expenses).toList();

    final freq = <Category, int>{};
    for (final e in allExpenses.where((e) => !e.isIncome)) {
      freq[e.category] = (freq[e.category] ?? 0) + 1;
    }
    final sortedFreq = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final recentCats =
        sortedFreq.take(6).map((e) => e.key).toList();

    final sortedExpenses = List<Expense>.from(allExpenses)
      ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));
    final recentExpenses = sortedExpenses.take(10).toList();

    final hasAmount = Money.parseToMinor(_amountCtrl.text) != null;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildAmountField(),
              const SizedBox(height: 12),
              _buildQuickAmountChips(),
              _buildRecentAmounts(recentExpenses),
              _buildPinnedPresets(),
              const SizedBox(height: 16),
              _buildRecentCategoryIcons(recentCats),
              _buildCategorySection(
                'Expense',
                Category.values.where((c) => !c.isIncome).toList(),
                _selectedCategory,
                (c) {
                  setState(() => _selectedCategory = c);
                  ref.read(expenseFormControllerProvider.notifier).setCategory(c);
                },
              ),
              const SizedBox(height: 8),
              _buildCategorySection(
                'Income',
                Category.values.where((c) => c.isIncome).toList(),
                _selectedCategory,
                (c) {
                  setState(() => _selectedCategory = c);
                  ref.read(expenseFormControllerProvider.notifier).setCategory(c);
                },
              ),
              _buildNotesField(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.mood_bad_outlined,
                      size: 16, color: AppTheme.expense),
                  const SizedBox(width: 8),
                  const Text('Waste',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  SizedBox(
                    height: 24,
                    child: Switch.adaptive(
                      value: state.isWaste,
                      activeColor: AppTheme.expense,
                      onChanged: (v) =>
                          ref.read(expenseFormControllerProvider.notifier)
                              .setIsWaste(v),
                    ),
                  ),
                ],
              ),
              if (state.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: const TextStyle(color: AppTheme.expense, fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectedCategory == null ? null : _savePreset,
                      icon: const Icon(Icons.push_pin_outlined, size: 18),
                      label: const Text('Save preset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: (hasAmount && _selectedCategory != null && !state.isSubmitting)
                          ? _submit
                          : null,
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text('Add Expense'),
                              ],
                            ),
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
}
