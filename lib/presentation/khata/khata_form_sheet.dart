import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/khata/khata_controller.dart';
import '../../application/providers.dart';
import '../../core/theme.dart';
import '../../core/money.dart';
import '../../domain/models/khata_entry.dart';

class KhataFormSheet extends ConsumerStatefulWidget {
  final KhataController notifier;
  final String? initialPerson;
  final String? initialPhone;
  final EntryType? initialType;

  const KhataFormSheet({
    super.key,
    required this.notifier,
    this.initialPerson,
    this.initialPhone,
    this.initialType,
  });

  @override
  ConsumerState<KhataFormSheet> createState() => _KhataFormSheetState();
}

class _KhataFormSheetState extends ConsumerState<KhataFormSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  EntryType _type = EntryType.lent;
  DateTime _date = DateTime.now();
  DateTime? _dueDate;
  bool _hasDueDate = false;
  bool _hasReminder = false;
  String _reminderFrequency = 'Once';
  List<String> _recentContacts = [];

  static const _amountPresets = ['500', '1000', '2000', '5000', '10000'];
  static const _noteTemplates = [
    'Salary advance',
    'Emergency',
    'Daily expense',
    'Monthly rent',
    'Groceries',
    'Medical',
    'Travel',
    'Shopping',
    'Loan installment',
    'Gift',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPerson != null) {
      _nameCtrl.text = widget.initialPerson!;
    }
    if (widget.initialPhone != null) {
      _phoneCtrl.text = widget.initialPhone!;
    }
    if (widget.initialType != null) {
      _type = widget.initialType!;
      if (_type == EntryType.repaymentReceived ||
          _type == EntryType.repaymentMade) {
        _hasDueDate = false;
      }
    }
    _nameCtrl.addListener(_onNameChanged);
    _loadRecentContacts();
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_onNameChanged);
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() {});
  }

  Future<void> _loadRecentContacts() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final stored = prefs.getStringList('recent_khata_contacts');
      if (stored != null && mounted) {
        setState(() => _recentContacts = stored);
      }
    } catch (_) {}
  }

  Future<void> _saveRecentContact(String name) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final updated = [name, ..._recentContacts.where((n) => n != name)]
          .take(10)
          .toList();
      await prefs.setStringList('recent_khata_contacts', updated);
      if (mounted) setState(() => _recentContacts = updated);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final state = ref.watch(khataControllerProvider);

    return Container(
      padding:
          EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottom + 24),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 20),
            const Text('Khata Entry',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            if (_recentContacts.isNotEmpty) ...[
              _RecentContactsRow(
                contacts: _recentContacts,
                onTap: (name) => setState(() {
                  _nameCtrl.text = name;
                  _nameCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: name.length));
                }),
              ),
              const SizedBox(height: 12),
            ],
            _TypeSelector(
              selected: _type,
              onChanged: (t) => setState(() {
                _type = t;
                if (t == EntryType.repaymentReceived ||
                    t == EntryType.repaymentMade) {
                  _hasDueDate = false;
                  _hasReminder = false;
                }
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _nameCtrl,
                    label: 'Person Name *',
                    hint: 'Enter name',
                    autofocus: widget.initialPerson == null,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() {
                    _nameCtrl.text = '';
                    _phoneCtrl.text = '';
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppTheme.primary.withAlpha(50)),
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: AppTheme.primary, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _phoneCtrl,
              label: 'Phone (optional)',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _buildField(
              controller: _amountCtrl,
              label: 'Amount *',
              hint: '0.00',
              prefix: '₹ ',
              keyboardType: TextInputType.number,
              autofocus: widget.initialPerson != null,
            ),
            const SizedBox(height: 8),
            _AmountPresets(
              presets: _amountPresets,
              onTap: (val) => setState(() {
                _amountCtrl.text = val;
                _amountCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: val.length));
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: 'Date',
                    date: _date,
                    onTap: _pickDate,
                  ),
                ),
                if (_type == EntryType.lent ||
                    _type == EntryType.borrowed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DueDateToggle(
                      hasDueDate: _hasDueDate,
                      dueDate: _dueDate,
                      onToggle: (v) => setState(() {
                        _hasDueDate = v;
                        if (!v) {
                          _hasReminder = false;
                          _dueDate = null;
                        }
                      }),
                      onPick: _pickDueDate,
                    ),
                  ),
                ],
              ],
            ),
            if (_hasDueDate) ...[
              const SizedBox(height: 12),
              _ReminderSection(
                hasReminder: _hasReminder,
                frequency: _reminderFrequency,
                onToggle: (v) => setState(() => _hasReminder = v),
                onFrequencyChanged: (v) =>
                    setState(() => _reminderFrequency = v),
              ),
            ],
            const SizedBox(height: 12),
            _buildField(
              controller: _notesCtrl,
              label: 'Notes (optional)',
            ),
            const SizedBox(height: 8),
            _NotesTemplates(
              templates: _noteTemplates,
              onTap: (text) => setState(() {
                final existing = _notesCtrl.text.trim();
                _notesCtrl.text = existing.isEmpty ? text : '$existing; $text';
                _notesCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: _notesCtrl.text.length));
              }),
            ),
            const SizedBox(height: 12),
            if (_nameCtrl.text.trim().isNotEmpty)
              _HistorySnapshot(
                entries: state.entries
                    .where((e) => e.personName
                        .toLowerCase()
                        .contains(_nameCtrl.text.trim().toLowerCase()))
                    .toList()
                  ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc)),
              ),
            const SizedBox(height: 16),
            _ValidationMessage(
              name: _nameCtrl.text.trim(),
              amount: _amountCtrl.text.trim(),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _submit,
              child: Text(_submitLabel),
            ),
          ],
        ),
      ),
    );
  }

  String get _submitLabel {
    switch (_type) {
      case EntryType.lent:
        return 'Add Lent Entry';
      case EntryType.borrowed:
        return 'Add Borrowed Entry';
      case EntryType.repaymentReceived:
        return 'Add Repayment Received';
      case EntryType.repaymentMade:
        return 'Add Repayment Made';
    }
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _date.add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person name is required')),
      );
      return;
    }

    final amount = Money.parseToMinor(_amountCtrl.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount greater than zero')),
      );
      return;
    }

    widget.notifier.addEntry(
      personName: name,
      phone: _phoneCtrl.text.isNotEmpty ? _phoneCtrl.text.trim() : null,
      amountMinor: amount,
      type: _type,
      dueDate: _hasDueDate ? _dueDate : null,
      notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    _saveRecentContact(name);

    Navigator.of(context).pop();
  }
}

class _RecentContactsRow extends StatelessWidget {
  final List<String> contacts;
  final ValueChanged<String> onTap;

  const _RecentContactsRow({
    required this.contacts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary)),
        const SizedBox(height: 8),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: contacts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final name = contacts[index];
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              return GestureDetector(
                onTap: () => onTap(name),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.primary.withAlpha(30),
                      child: Text(initial,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 48,
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final EntryType selected;
  final ValueChanged<EntryType> onChanged;

  const _TypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      EntryType.lent,
      EntryType.borrowed,
      EntryType.repaymentReceived,
      EntryType.repaymentMade,
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = type == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _colorForType(type).withAlpha(30)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForType(type),
                      size: 18,
                      color: isSelected
                          ? _colorForType(type)
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.shortLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? _colorForType(type)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _colorForType(EntryType type) {
    switch (type) {
      case EntryType.lent:
        return AppTheme.income;
      case EntryType.borrowed:
        return AppTheme.expense;
      case EntryType.repaymentReceived:
        return AppTheme.primary;
      case EntryType.repaymentMade:
        return AppTheme.warning;
    }
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
}

class _AmountPresets extends StatelessWidget {
  final List<String> presets;
  final ValueChanged<String> onTap;

  const _AmountPresets({
    required this.presets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.map((val) {
        return GestureDetector(
          onTap: () => onTap(val),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primary.withAlpha(40)),
            ),
            child: Text(
              '₹ $val',
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueDateToggle extends StatelessWidget {
  final bool hasDueDate;
  final DateTime? dueDate;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPick;

  const _DueDateToggle({
    required this.hasDueDate,
    required this.dueDate,
    required this.onToggle,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDueDate) {
      return InkWell(
        onTap: () => onToggle(true),
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
              Text('Due Date',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              const Text('+ Add',
                  style: TextStyle(
                      color: AppTheme.primary, fontSize: 15)),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.bg.withAlpha(100),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warning.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Due Date',
                    style: TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const Spacer(),
                GestureDetector(
                  onTap: () => onToggle(false),
                  child: Icon(Icons.close,
                      size: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              dueDate != null
                  ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}'
                  : 'Select date',
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  final bool hasReminder;
  final String frequency;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onFrequencyChanged;

  static const _frequencies = ['Once', 'Daily', 'Weekly', 'Monthly'];

  const _ReminderSection({
    required this.hasReminder,
    required this.frequency,
    required this.onToggle,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text('Reminder',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              const Spacer(),
              Switch(
                value: hasReminder,
                onChanged: onToggle,
                activeColor: AppTheme.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (hasReminder) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Notify',
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: frequency,
                        isExpanded: true,
                        dropdownColor: AppTheme.cardSurface,
                        style: const TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13),
                        items: _frequencies.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Row(
                              children: [
                                Icon(
                                  _iconForFrequency(f),
                                  size: 16,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(f),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) onFrequencyChanged(v);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForFrequency(String f) {
    switch (f) {
      case 'Once':
        return Icons.notifications_active_rounded;
      case 'Daily':
        return Icons.repeat_rounded;
      case 'Weekly':
        return Icons.date_range_rounded;
      case 'Monthly':
        return Icons.calendar_month_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}

class _NotesTemplates extends StatelessWidget {
  final List<String> templates;
  final ValueChanged<String> onTap;

  const _NotesTemplates({
    required this.templates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: templates.map((text) {
        return GestureDetector(
          onTap: () => onTap(text),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bg.withAlpha(120),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(
              text,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HistorySnapshot extends StatelessWidget {
  final List<KhataEntry> entries;

  const _HistorySnapshot({
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final display = entries.length > 3 ? entries.sublist(0, 3) : entries;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bg.withAlpha(80),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                entries.length > 3
                    ? 'Last 3 entries (${entries.length} total)'
                    : '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...display.map((e) => _buildEntryRow(e)),
        ],
      ),
    );
  }

  Widget _buildEntryRow(KhataEntry entry) {
    final date =
        '${entry.localDate.day}/${entry.localDate.month}/${entry.localDate.year}';
    final isPositive = entry.netEffect > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            _iconForType(entry.type),
            size: 14,
            color: isPositive ? AppTheme.income : AppTheme.expense,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              entry.type.shortLabel,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            date,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 8),
          Text(
            entry.amountFormatted,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppTheme.income : AppTheme.expense,
            ),
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
}

class _ValidationMessage extends StatelessWidget {
  final String name;
  final String amount;

  const _ValidationMessage({
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final errors = <String>[];
    if (name.isEmpty) {
      errors.add('Person name is required');
    }
    if (amount.isEmpty) {
      errors.add('Amount is required');
    } else if (Money.parseToMinor(amount) == null) {
      errors.add('Amount must be greater than zero');
    }

    if (errors.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.expense.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.expense.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    size: 14, color: AppTheme.expense),
                const SizedBox(width: 6),
                Text(e,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.expense)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
