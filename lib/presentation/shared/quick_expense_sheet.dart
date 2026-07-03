import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/theme.dart';
import '../expense/expense_form_screen.dart';

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

class _QuickExpenseSheetState extends ConsumerState<QuickExpenseSheet> {
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  Category? _selectedCategory;

  static const _quickAmounts = [50, 100, 200, 500, 1000, 2000];

  Widget _buildCategorySection(
      String title, List<Category> cats, Category? selected,
      ValueChanged<Category> onTap) {
    if (cats.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5)),
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
                    Text(c.label,
                        style: TextStyle(
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                            color:
                                sel ? c.color : AppTheme.textPrimary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

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
    super.dispose();
  }

  void _setQuickAmount(int amount) {
    _amountCtrl.text = amount.toString();
    _amountCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountCtrl.text.length),
    );
    ref
        .read(expenseFormControllerProvider.notifier)
        .setAmount(amount.toString());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final state = ref.watch(expenseFormControllerProvider);
    final notifier = ref.read(expenseFormControllerProvider.notifier);

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Quick Expense',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ExpenseFormScreen()));
                  },
                  child: const Text('Full Form'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bg.withAlpha(100),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _amountCtrl,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  hintText: '0.00',
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: notifier.setAmount,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((a) {
                final isSelected = _amountCtrl.text == a.toString();
                return GestureDetector(
                  onTap: () => _setQuickAmount(a),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withAlpha(30)
                          : AppTheme.cardGlass,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                      ),
                    ),
                    child: Text('₹$a',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            _buildCategorySection(
              'Expense',
              Category.values.where((c) => !c.isIncome).toList(),
              _selectedCategory,
              (c) {
                setState(() => _selectedCategory = c);
                notifier.setCategory(c);
              },
            ),
            const SizedBox(height: 8),
            _buildCategorySection(
              'Income',
              Category.values.where((c) => c.isIncome).toList(),
              _selectedCategory,
              (c) {
                setState(() => _selectedCategory = c);
                notifier.setCategory(c);
              },
            ),
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
                onChanged: notifier.setNotes,
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!,
                  style:
                      const TextStyle(color: AppTheme.expense, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: state.isSubmitting
                  ? null
                  : () async {
                      final success = await notifier.submit();
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
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
                        Icon(Icons.add_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Add Expense'),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
