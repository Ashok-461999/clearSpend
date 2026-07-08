import '../../core/money.dart';

enum EntryType { lent, borrowed, repaymentReceived, repaymentMade }

extension EntryTypeX on EntryType {
  String get label {
    switch (this) {
      case EntryType.lent:
        return 'Lent';
      case EntryType.borrowed:
        return 'Borrowed';
      case EntryType.repaymentReceived:
        return 'Repayment Received';
      case EntryType.repaymentMade:
        return 'Repayment Made';
    }
  }

  String get shortLabel {
    switch (this) {
      case EntryType.lent:
        return 'Lent';
      case EntryType.borrowed:
        return 'Borrowed';
      case EntryType.repaymentReceived:
        return 'Received';
      case EntryType.repaymentMade:
        return 'Repaid';
    }
  }
}

class KhataEntry {
  final int? id;
  final String personName;
  final String? phone;
  final int amountMinor;
  final EntryType type;
  final DateTime dateUtc;
  final DateTime? dueDate;
  final String? notes;

  const KhataEntry({
    this.id,
    required this.personName,
    this.phone,
    required this.amountMinor,
    required this.type,
    required this.dateUtc,
    this.dueDate,
    this.notes,
  });

  DateTime get localDate => dateUtc.toLocal();

  int get netEffect {
    switch (type) {
      case EntryType.lent:
        return amountMinor;
      case EntryType.borrowed:
        return -amountMinor;
      case EntryType.repaymentReceived:
        return -amountMinor;
      case EntryType.repaymentMade:
        return amountMinor;
    }
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day + 1));
  }

  String get amountFormatted => Money.format(amountMinor);

  KhataEntry copyWith({
    int? id,
    String? personName,
    String? phone,
    int? amountMinor,
    EntryType? type,
    DateTime? dateUtc,
    DateTime? dueDate,
    String? notes,
    bool clearId = false,
  }) {
    return KhataEntry(
      id: clearId ? null : (id ?? this.id),
      personName: personName ?? this.personName,
      phone: phone ?? this.phone,
      amountMinor: amountMinor ?? this.amountMinor,
      type: type ?? this.type,
      dateUtc: dateUtc ?? this.dateUtc,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
    );
  }
}
