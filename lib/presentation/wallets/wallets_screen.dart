import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../core/money.dart';

// ────────────────────────────────────────────────────────────────────────
// Models
// ────────────────────────────────────────────────────────────────────────

enum WalletType { cash, bank, upi }

extension WalletTypeX on WalletType {
  String get label {
    switch (this) {
      case WalletType.cash:
        return 'Cash';
      case WalletType.bank:
        return 'Bank Account';
      case WalletType.upi:
        return 'UPI';
    }
  }

  IconData get icon {
    switch (this) {
      case WalletType.cash:
        return Icons.money;
      case WalletType.bank:
        return Icons.account_balance;
      case WalletType.upi:
        return Icons.payments;
    }
  }

  Color get color {
    switch (this) {
      case WalletType.cash:
        return AppTheme.income;
      case WalletType.bank:
        return AppTheme.primary;
      case WalletType.upi:
        return AppTheme.accent;
    }
  }
}

enum TransactionType { credit, debit, transfer }

class WalletTransaction {
  final String id;
  final int amountMinor;
  final String description;
  final DateTime date;
  final TransactionType type;
  final String? targetWalletId;

  const WalletTransaction({
    required this.id,
    required this.amountMinor,
    required this.description,
    required this.date,
    required this.type,
    this.targetWalletId,
  });
}

class Wallet {
  final String id;
  final String name;
  final WalletType type;
  final int balanceMinor;
  final List<WalletTransaction> transactions;

  const Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.balanceMinor,
    this.transactions = const [],
  });

  Wallet copyWith({
    String? id,
    String? name,
    WalletType? type,
    int? balanceMinor,
    List<WalletTransaction>? transactions,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      transactions: transactions ?? this.transactions,
    );
  }

  WalletTransaction? get lastTransaction =>
      transactions.isEmpty ? null : transactions.first;
}

// ────────────────────────────────────────────────────────────────────────
// State & Notifier
// ────────────────────────────────────────────────────────────────────────

class WalletsState {
  final List<Wallet> wallets;
  final String? selectedWalletId;

  const WalletsState({
    this.wallets = const [],
    this.selectedWalletId,
  });

  WalletsState copyWith({
    List<Wallet>? wallets,
    String? selectedWalletId,
  }) {
    return WalletsState(
      wallets: wallets ?? this.wallets,
      selectedWalletId: selectedWalletId ?? this.selectedWalletId,
    );
  }

  Wallet? get selectedWallet =>
      selectedWalletId == null ? null : wallets.cast<Wallet?>().firstWhere(
            (w) => w!.id == selectedWalletId,
            orElse: () => null,
          );

  int get netWorth =>
      wallets.fold(0, (sum, w) => sum + w.balanceMinor);
}

class WalletsNotifier extends StateNotifier<WalletsState> {
  WalletsNotifier() : super(const WalletsState());

  int _nextId = 1;

  void addWallet(String name, WalletType type, int initialBalanceMinor) {
    final id = 'wallet_${_nextId++}';
    var wallet = Wallet(
      id: id,
      name: name,
      type: type,
      balanceMinor: initialBalanceMinor,
    );
    List<WalletTransaction> txs = [];
    if (initialBalanceMinor > 0) {
      txs = [
        WalletTransaction(
          id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
          amountMinor: initialBalanceMinor,
          description: 'Opening balance',
          date: DateTime.now(),
          type: TransactionType.credit,
        ),
      ];
      wallet = wallet.copyWith(
        balanceMinor: initialBalanceMinor,
        transactions: txs,
      );
    }
    state = state.copyWith(wallets: [...state.wallets, wallet]);
  }

  void editWallet(String id, String name, WalletType type) {
    state = state.copyWith(
      wallets: state.wallets.map((w) {
        if (w.id != id) return w;
        return w.copyWith(name: name, type: type);
      }).toList(),
    );
  }

  void deleteWallet(String id) {
    state = state.copyWith(
      wallets: state.wallets.where((w) => w.id != id).toList(),
      selectedWalletId:
          state.selectedWalletId == id ? null : state.selectedWalletId,
    );
  }

  void addTransaction(
    String walletId,
    int amountMinor,
    String description,
    TransactionType type, {
    String? targetWalletId,
  }) {
    final tx = WalletTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}_${walletId}',
      amountMinor: amountMinor,
      description: description,
      date: DateTime.now(),
      type: type,
      targetWalletId: targetWalletId,
    );
    state = state.copyWith(
      wallets: state.wallets.map((w) {
        if (w.id != walletId) return w;
        final newBalance = type == TransactionType.credit
            ? w.balanceMinor + amountMinor
            : w.balanceMinor - amountMinor;
        return w.copyWith(
          balanceMinor: newBalance,
          transactions: [tx, ...w.transactions],
        );
      }).toList(),
    );
  }

  void transfer(int amountMinor, String fromId, String toId) {
    addTransaction(
      fromId,
      amountMinor,
      'Transfer to ${state.wallets.firstWhere((w) => w.id == toId).name}',
      TransactionType.debit,
      targetWalletId: toId,
    );
    addTransaction(
      toId,
      amountMinor,
      'Transfer from ${state.wallets.firstWhere((w) => w.id == fromId).name}',
      TransactionType.credit,
      targetWalletId: fromId,
    );
  }

  void selectWallet(String? id) {
    state = state.copyWith(selectedWalletId: id);
  }
}

final walletsProvider =
    StateNotifierProvider<WalletsNotifier, WalletsState>((ref) {
  return WalletsNotifier();
});

// ────────────────────────────────────────────────────────────────────────
// Main Screen
// ────────────────────────────────────────────────────────────────────────

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows),
            tooltip: 'Transfer',
            onPressed: state.wallets.length >= 2
                ? () => _showTransferDialog(context, ref)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Wallet',
            onPressed: () => _showAddWalletDialog(context, ref),
          ),
        ],
      ),
      body: state.wallets.isEmpty
          ? _EmptyState(onAdd: () => _showAddWalletDialog(context, ref))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _NetWorthCard(netWorth: state.netWorth),
                const SizedBox(height: 8),
                Text('Your Wallets', style: AppTheme.sectionTitle),
                const SizedBox(height: 8),
                ...state.wallets.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _WalletCard(
                      wallet: w,
                      onTap: () => _showWalletDetail(context, ref, w),
                      onEdit: () => _showEditWalletDialog(context, ref, w),
                      onDelete: () => _confirmDelete(context, ref, w),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddWalletDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _WalletFormDialog(
        title: 'Add Wallet',
        onSave: (name, type, balance) {
          ref.read(walletsProvider.notifier).addWallet(name, type, balance);
        },
      ),
    );
  }

  void _showEditWalletDialog(
      BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => _WalletFormDialog(
        title: 'Edit Wallet',
        initialName: wallet.name,
        initialType: wallet.type,
        hideBalance: true,
        onSave: (name, type, _) {
          ref.read(walletsProvider.notifier).editWallet(wallet.id, name, type);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Wallet',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${wallet.name}"? This action cannot be undone.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(walletsProvider.notifier).deleteWallet(wallet.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _TransferDialog(),
    );
  }

  void _showWalletDetail(
      BuildContext context, WidgetRef ref, Wallet wallet) {
    ref.read(walletsProvider.notifier).selectWallet(wallet.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _WalletDetailScreen(walletId: wallet.id),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Empty State
// ────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 72, color: AppTheme.textSecondary.withAlpha(80)),
            const SizedBox(height: 16),
            const Text('No wallets yet',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            const Text('Add your first wallet to start tracking',
                style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Wallet'),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Net Worth Card
// ────────────────────────────────────────────────────────────────────────

class _NetWorthCard extends StatelessWidget {
  final int netWorth;
  const _NetWorthCard({required this.netWorth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withAlpha(40),
            AppTheme.accent.withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Net Worth',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Money.format(netWorth),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Wallet Card
// ────────────────────────────────────────────────────────────────────────

class _WalletCard extends StatelessWidget {
  final Wallet wallet;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WalletCard({
    required this.wallet,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = wallet.type.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(200),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(wallet.type.icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(wallet.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(wallet.type.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: color)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Money.format(wallet.balanceMinor),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      if (wallet.lastTransaction != null)
                        Text(
                          wallet.lastTransaction!.type == TransactionType.credit
                              ? '+${Money.format(wallet.lastTransaction!.amountMinor)}'
                              : '-${Money.format(wallet.lastTransaction!.amountMinor)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: wallet.lastTransaction!.type ==
                                    TransactionType.credit
                                ? AppTheme.income
                                : AppTheme.expense,
                          ),
                        )
                      else
                        const Text('No transactions',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: AppTheme.textSecondary, size: 20),
                    color: AppTheme.cardSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18,
                                color: AppTheme.textSecondary),
                            SizedBox(width: 10),
                            Text('Edit',
                                style: TextStyle(color: AppTheme.textPrimary)),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18,
                                color: AppTheme.expense),
                            SizedBox(width: 10),
                            Text('Delete',
                                style: TextStyle(color: AppTheme.expense)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (wallet.lastTransaction != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSecondary.withAlpha(120),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz,
                          size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wallet.lastTransaction!.description,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Wallet Form Dialog (Add / Edit)
// ────────────────────────────────────────────────────────────────────────

class _WalletFormDialog extends StatefulWidget {
  final String title;
  final String? initialName;
  final WalletType? initialType;
  final bool hideBalance;
  final void Function(String name, WalletType type, int balanceMinor) onSave;

  const _WalletFormDialog({
    required this.title,
    this.initialName,
    this.initialType,
    this.hideBalance = false,
    required this.onSave,
  });

  @override
  State<_WalletFormDialog> createState() => _WalletFormDialogState();
}

class _WalletFormDialogState extends State<_WalletFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _balanceCtrl;
  late WalletType _type;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _balanceCtrl = TextEditingController();
    _type = widget.initialType ?? WalletType.cash;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(widget.title,
          style: const TextStyle(color: AppTheme.textPrimary)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Wallet Name',
                  prefixIcon: Icon(Icons.wallet, color: AppTheme.textSecondary),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WalletType>(
                value: _type,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Wallet Type',
                  prefixIcon:
                      Icon(Icons.category, color: AppTheme.textSecondary),
                ),
                items: WalletType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 18, color: t.color),
                        const SizedBox(width: 10),
                        Text(t.label),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              if (!widget.hideBalance) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _balanceCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Initial Balance (₹)',
                    prefixIcon:
                        Icon(Icons.currency_rupee, color: AppTheme.textSecondary),
                  ),
                  validator: (v) {
                    if (widget.hideBalance) return null;
                    if (v == null || v.trim().isEmpty) return 'Enter balance';
                    if (Money.parseToMinor(v) == null) return 'Invalid amount';
                    return null;
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final name = _nameCtrl.text.trim();
            final balance = widget.hideBalance
                ? 0
                : (Money.parseToMinor(_balanceCtrl.text) ?? 0);
            widget.onSave(name, _type, balance);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Transfer Dialog
// ────────────────────────────────────────────────────────────────────────

class _TransferDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends ConsumerState<_TransferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  String? _fromId;
  String? _toId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.read(walletsProvider).wallets;
    final availableFrom =
        wallets.where((w) => w.id != _toId).toList();
    final availableTo =
        wallets.where((w) => w.id != _fromId).toList();

    return AlertDialog(
      backgroundColor: AppTheme.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.compare_arrows, color: AppTheme.primary, size: 22),
          SizedBox(width: 10),
          Text('Transfer', style: TextStyle(color: AppTheme.textPrimary)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _fromId,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'From',
                  prefixIcon:
                      Icon(Icons.arrow_upward, color: AppTheme.expense),
                ),
                items: availableFrom.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Text('${w.name} (${Money.format(w.balanceMinor)})'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _fromId = v),
                validator: (v) => v == null ? 'Select source wallet' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _toId,
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'To',
                  prefixIcon:
                      Icon(Icons.arrow_downward, color: AppTheme.income),
                ),
                items: availableTo.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Text('${w.name} (${Money.format(w.balanceMinor)})'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _toId = v),
                validator: (v) => v == null ? 'Select destination wallet' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  prefixIcon:
                      Icon(Icons.currency_rupee, color: AppTheme.textSecondary),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter amount';
                  final parsed = Money.parseToMinor(v);
                  if (parsed == null) return 'Invalid amount';
                  final fromWallet = wallets.firstWhere(
                    (w) => w.id == _fromId,
                    orElse: () => wallets.first,
                  );
                  if (parsed > fromWallet.balanceMinor) {
                    return 'Insufficient balance';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final amount = Money.parseToMinor(_amountCtrl.text)!;
            ref
                .read(walletsProvider.notifier)
                .transfer(amount, _fromId!, _toId!);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transfer completed'),
                backgroundColor: AppTheme.cardSurface,
              ),
            );
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Wallet Detail Screen (Transaction List)
// ────────────────────────────────────────────────────────────────────────

class _WalletDetailScreen extends ConsumerWidget {
  final String walletId;
  const _WalletDetailScreen({required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletsProvider).wallets;
    final wallet = wallets.cast<Wallet?>().firstWhere(
          (w) => w!.id == walletId,
          orElse: () => null,
        );

    if (wallet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wallet')),
        body: const Center(
          child: Text('Wallet not found',
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }

    final color = wallet.type.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, ref, wallet),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, wallet),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Header card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(40), color.withAlpha(10)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(wallet.type.icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(wallet.name,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(wallet.type.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: color)),
                ),
                const SizedBox(height: 16),
                const Text('Current Balance',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  Money.format(wallet.balanceMinor),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transactions',
                  style: AppTheme.sectionTitle),
              Text('${wallet.transactions.length} entries',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          if (wallet.transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface.withAlpha(150),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 40, color: AppTheme.textSecondary),
                  SizedBox(height: 8),
                  Text('No transactions yet',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          else
            ...wallet.transactions.map((tx) => _TransactionTile(tx: tx)),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => _WalletFormDialog(
        title: 'Edit Wallet',
        initialName: wallet.name,
        initialType: wallet.type,
        hideBalance: true,
        onSave: (name, type, _) {
          ref.read(walletsProvider.notifier).editWallet(wallet.id, name, type);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Wallet wallet) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Wallet',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${wallet.name}"? This will remove all transaction history.',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(walletsProvider.notifier).deleteWallet(wallet.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppTheme.expense)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────
// Transaction Tile
// ────────────────────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final WalletTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == TransactionType.credit;
    final isTransfer = tx.type == TransactionType.transfer;

    IconData icon;
    Color iconColor;
    if (isTransfer) {
      icon = Icons.compare_arrows;
      iconColor = AppTheme.warning;
    } else if (isCredit) {
      icon = Icons.arrow_downward;
      iconColor = AppTheme.income;
    } else {
      icon = Icons.arrow_upward;
      iconColor = AppTheme.expense;
    }

    final dateStr =
        '${tx.date.day}/${tx.date.month}/${tx.date.year} ${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(180),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(dateStr,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}${Money.format(tx.amountMinor)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isCredit ? AppTheme.income : AppTheme.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
