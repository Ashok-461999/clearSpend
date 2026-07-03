import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emi/emi_controller.dart';
import '../../application/providers.dart';
import '../../core/category.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/emi.dart';

class EmisScreen extends ConsumerWidget {
  const EmisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emiControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMIs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: state.emis.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface.withAlpha(100),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.calendar_month_outlined,
                        size: 48, color: AppTheme.textSecondary.withAlpha(100)),
                  ),
                  const SizedBox(height: 16),
                  const Text('No EMIs yet',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('Tap + to add your first EMI',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.emis.length,
              itemBuilder: (context, index) => _EmiCard(
                    emi: state.emis[index],
                    onMarkPaid: () => ref
                        .read(emiControllerProvider.notifier)
                        .markPaid(state.emis[index].id!),
                    onDelete: () => ref
                        .read(emiControllerProvider.notifier)
                        .deleteEmi(state.emis[index].id!),
                  ),
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(emiControllerProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EmiForm(notifier: notifier),
    );
  }
}

class _EmiForm extends StatefulWidget {
  final EmiController notifier;
  const _EmiForm({required this.notifier});

  @override
  State<_EmiForm> createState() => _EmiFormState();
}

class _EmiFormState extends State<_EmiForm> {
  final _nameCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  final _monthsCtrl = TextEditingController(text: '12');
  final _notesCtrl = TextEditingController();
  Category _category = Category.housing;
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalCtrl.dispose();
    _monthlyCtrl.dispose();
    _monthsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottom + 24),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
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
          const Text('Add EMI',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          _buildField(
            controller: _nameCtrl,
            label: 'EMI Name',
            hint: 'e.g. Home Loan, Car Loan',
            autofocus: true,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _totalCtrl,
                  label: 'Total Amount',
                  hint: '0.00',
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  controller: _monthlyCtrl,
                  label: 'Monthly EMI',
                  hint: '0.00',
                  prefix: '₹ ',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _monthsCtrl,
                  label: 'Total Months',
                  hint: '12',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.bg.withAlpha(100),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Date',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.bg.withAlpha(100),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: DropdownButtonFormField<Category>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: InputBorder.none,
              ),
              dropdownColor: AppTheme.cardSurface,
              style: const TextStyle(color: AppTheme.textPrimary),
              items: Category.values
                  .where((c) => !c.isIncome)
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(c.icon, size: 18, color: c.color),
                            const SizedBox(width: 8),
                            Text(c.label),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
          ),
          const SizedBox(height: 12),
          _buildField(
            controller: _notesCtrl,
            label: 'Notes (optional)',
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submit,
            child: const Text('Add EMI'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
    TextInputType? keyboardType,
    bool autofocus = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefix,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _submit() {
    final total = Money.parseToMinor(_totalCtrl.text);
    final monthly = Money.parseToMinor(_monthlyCtrl.text);
    final months = int.tryParse(_monthsCtrl.text.trim()) ?? 12;
    if (total == null || monthly == null || months <= 1) return;
    widget.notifier.addEmi(
      name: _nameCtrl.text,
      totalAmountMinor: total,
      monthlyAmountMinor: monthly,
      category: _category,
      startDate: _startDate,
      totalMonths: months,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
    );
    Navigator.of(context).pop();
  }
}

class _EmiCard extends StatelessWidget {
  final Emi emi;
  final VoidCallback onMarkPaid;
  final VoidCallback onDelete;
  const _EmiCard({
    required this.emi,
    required this.onMarkPaid,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: emi.category.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(emi.category.icon,
                      color: emi.category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(emi.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textPrimary)),
                      Text(emi.category.label,
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(emi.monthlyFormatted,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.textPrimary)),
                    Text('/mo',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'paid') onMarkPaid();
                    if (v == 'delete') onDelete();
                  },
                  icon: const Icon(Icons.more_vert,
                      color: AppTheme.textSecondary),
                  color: AppTheme.cardSurface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  itemBuilder: (_) => [
                    if (!emi.isCompleted)
                      const PopupMenuItem(
                        value: 'paid',
                        child: ListTile(
                          leading: Icon(Icons.check_circle_outline,
                              color: AppTheme.income),
                          title: Text('Mark Paid',
                              style: TextStyle(color: AppTheme.textPrimary)),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline,
                            color: AppTheme.expense),
                        title: Text('Delete',
                            style: TextStyle(color: AppTheme.textPrimary)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: emi.progress,
                backgroundColor: emi.category.color.withAlpha(20),
                valueColor:
                    AlwaysStoppedAnimation<Color>(emi.isCompleted
                        ? AppTheme.income
                        : emi.category.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${emi.paidMonths}/${emi.totalMonths} months',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary)),
                const Spacer(),
                if (emi.isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.incomeGlass,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Paid off',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.income)),
                  )
                else
                  Text(
                    'Due: ${emi.nextDueDate.day}/${emi.nextDueDate.month}/${emi.nextDueDate.year}',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
