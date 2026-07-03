import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/theme.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _notesCtrl = TextEditingController();

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
          spacing: 10,
          runSpacing: 10,
          children: cats.map((c) {
            final sel = selected == c;
            return GestureDetector(
              onTap: () => onTap(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
                            fontWeight:
                                sel ? FontWeight.w600 : FontWeight.w500,
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

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(expenseFormControllerProvider);
    final notifier = ref.read(expenseFormControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.editingId == null ? 'Add Expense' : 'Edit Expense'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Amount',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bg.withAlpha(100),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextFormField(
                key: ValueKey('amount_${state.editingId ?? 'new'}'),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                initialValue: state.amountText,
                onChanged: notifier.setAmount,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 10),
            _buildCategorySection(
              'Expense',
              Category.values.where((c) => !c.isIncome).toList(),
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
            const Text('Notes',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.bg.withAlpha(100),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextFormField(
                key: ValueKey('notes_${state.editingId ?? 'new'}'),
                decoration: const InputDecoration(
                  hintText: 'What did you spend on?',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
                maxLines: 2,
                initialValue: state.notes,
                onChanged: notifier.setNotes,
              ),
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
                      final success = await notifier.submit();
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
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
