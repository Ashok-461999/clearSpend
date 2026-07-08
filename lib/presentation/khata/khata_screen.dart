import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/khata/khata_controller.dart';
import '../../application/providers.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../domain/models/khata_entry.dart';
import 'khata_form_sheet.dart';

class KhataScreen extends ConsumerWidget {
  const KhataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(khataControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Khata'),
        actions: [
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.error_outline,
                  color: AppTheme.expense, size: 20),
            ),
        ],
      ),
      body: state.entries.isEmpty
          ? _EmptyState()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                _NetSummaryCard(state: state),
                const SizedBox(height: 16),
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(state.error!,
                        style: const TextStyle(
                            color: AppTheme.expense, fontSize: 13)),
                  ),
                ...state.persons.map(
                    (p) => _PersonCard(person: p, ref: ref)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KhataFormSheet(
        notifier: ref.read(khataControllerProvider.notifier),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.book_outlined,
                size: 48,
                color: AppTheme.textSecondary.withAlpha(100)),
          ),
          const SizedBox(height: 16),
          const Text('No Khata entries yet',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Tap + to track lending & borrowing',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }
}

class _NetSummaryCard extends StatelessWidget {
  final KhataState state;
  const _NetSummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final net = state.totalYouAreOwed - state.totalYouOwe;
    final netColor = net >= 0 ? AppTheme.income : AppTheme.expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withAlpha(40),
            AppTheme.cardSurface.withAlpha(200),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'You are owed',
                  amount: state.totalYouAreOwed,
                  color: AppTheme.income,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryTile(
                  label: 'You owe',
                  amount: state.totalYouOwe,
                  color: AppTheme.expense,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(100),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Icon(
                  net >= 0
                      ? Icons.account_balance_wallet_rounded
                      : Icons.warning_amber_rounded,
                  color: netColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text('Net Position',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary)),
                const Spacer(),
                Text(
                  net >= 0 ? Money.format(net) : '-${Money.format(net.abs())}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: netColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            amount > 0 ? Money.format(amount) : '₹0',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonCard extends ConsumerWidget {
  final PersonSummary person;
  final WidgetRef ref;
  const _PersonCard({required this.person, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwed = person.balance >= 0;
    final balanceColor = isOwed ? AppTheme.income : AppTheme.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: person.isOverdue
            ? AppTheme.expense.withAlpha(12)
            : AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: person.isOverdue
              ? AppTheme.expense.withAlpha(80)
              : AppTheme.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primary,
            surface: Colors.transparent,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isOwed
                  ? AppTheme.income.withAlpha(25)
                  : AppTheme.expense.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              person.phone != null && person.phone!.isNotEmpty
                  ? Icons.person_rounded
                  : Icons.person_outline_rounded,
              color: balanceColor,
              size: 22,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(person.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary)),
              ),
              Text(
                isOwed
                    ? Money.format(person.balance)
                    : '-${Money.format(person.balance.abs())}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: balanceColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                isOwed ? 'They owe you' : 'You owe them',
                style: TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
              if (person.isOverdue) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.expense.withAlpha(40),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('OVERDUE',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.expense)),
                ),
              ],
              if (person.nearestDueDate != null && !person.isOverdue) ...[
                const SizedBox(width: 8),
                Text(
                  'Due ${person.nearestDueDate!.day}/${person.nearestDueDate!.month}',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.warning),
                ),
              ],
            ],
          ),
          children: [
            ...person.entries.map(
              (e) => _EntryRow(entry: e, ref: ref),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showRepayment(context, ref),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: Text(
                    isOwed ? 'Record Repayment from Them' : 'Repay Them'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  minimumSize: const Size(double.infinity, 42),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRepayment(BuildContext context, WidgetRef ref) {
    final isOwed = person.balance >= 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KhataFormSheet(
        notifier: ref.read(khataControllerProvider.notifier),
        initialPerson: person.name,
        initialPhone: person.phone,
        initialType:
            isOwed ? EntryType.repaymentReceived : EntryType.repaymentMade,
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final KhataEntry entry;
  final WidgetRef ref;
  const _EntryRow({required this.entry, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isPositiveEffect = entry.netEffect > 0;
    final color = isPositiveEffect ? AppTheme.income : AppTheme.expense;
    final icon = _iconForType(entry.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.type.shortLabel} ${entry.amountFormatted}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary),
                ),
                Row(
                  children: [
                    Text(
                      '${entry.localDate.day}/${entry.localDate.month}/${entry.localDate.year}',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    if (entry.dueDate != null) ...[
                      const Text('  ·  ',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                      Text('Due ${entry.dueDate!.day}/${entry.dueDate!.month}/${entry.dueDate!.year}',
                          style: TextStyle(
                              fontSize: 11,
                              color: entry.isOverdue
                                  ? AppTheme.expense
                                  : AppTheme.textSecondary)),
                    ],
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      const Text('  ·  ',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                      Expanded(
                        child: Text(entry.notes!,
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Icon(Icons.delete_outline,
                size: 18, color: AppTheme.textSecondary.withAlpha(100)),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(EntryType type) {
    switch (type) {
      case EntryType.lent:
        return Icons.arrow_upward_rounded;
      case EntryType.borrowed:
        return Icons.arrow_downward_rounded;
      case EntryType.repaymentReceived:
        return Icons.call_received_rounded;
      case EntryType.repaymentMade:
        return Icons.call_made_rounded;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        title: const Text('Delete entry?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(khataControllerProvider.notifier)
                  .deleteEntry(entry.id!);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}
