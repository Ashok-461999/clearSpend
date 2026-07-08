import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/khata_entry.dart';
import '../../domain/repositories/khata_repository.dart';

class PersonSummary {
  final String name;
  final String? phone;
  final int balance;
  final List<KhataEntry> entries;
  final bool isOverdue;
  final DateTime? nearestDueDate;

  const PersonSummary({
    required this.name,
    this.phone,
    required this.balance,
    required this.entries,
    required this.isOverdue,
    this.nearestDueDate,
  });

  PersonSummary copyWith({
    String? name,
    String? phone,
    int? balance,
    List<KhataEntry>? entries,
    bool? isOverdue,
    DateTime? nearestDueDate,
  }) {
    return PersonSummary(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      entries: entries ?? this.entries,
      isOverdue: isOverdue ?? this.isOverdue,
      nearestDueDate: nearestDueDate ?? this.nearestDueDate,
    );
  }
}

class KhataState {
  final List<KhataEntry> entries;
  final List<PersonSummary> persons;
  final int totalYouAreOwed;
  final int totalYouOwe;
  final String? error;

  const KhataState({
    this.entries = const [],
    this.persons = const [],
    this.totalYouAreOwed = 0,
    this.totalYouOwe = 0,
    this.error,
  });

  KhataState copyWith({
    List<KhataEntry>? entries,
    List<PersonSummary>? persons,
    int? totalYouAreOwed,
    int? totalYouOwe,
    String? error,
    bool clearError = false,
  }) {
    return KhataState(
      entries: entries ?? this.entries,
      persons: persons ?? this.persons,
      totalYouAreOwed: totalYouAreOwed ?? this.totalYouAreOwed,
      totalYouOwe: totalYouOwe ?? this.totalYouOwe,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class KhataController extends StateNotifier<KhataState> {
  final KhataRepository _repository;
  StreamSubscription<List<KhataEntry>>? _subscription;

  KhataController(this._repository) : super(const KhataState()) {
    try {
      _subscription = _repository.watchAll().listen(_onEntriesChanged);
    } catch (_) {
      state = state.copyWith(error: 'Restart app to enable Khata storage');
    }
  }

  void _onEntriesChanged(List<KhataEntry> entries) {
    final persons = _computePersons(entries);
    int totalOwed = 0;
    int totalOwe = 0;
    for (final p in persons) {
      if (p.balance > 0) {
        totalOwed += p.balance;
      } else if (p.balance < 0) {
        totalOwe += p.balance.abs();
      }
    }
    state = state.copyWith(
      entries: entries,
      persons: persons,
      totalYouAreOwed: totalOwed,
      totalYouOwe: totalOwe,
    );
  }

  List<PersonSummary> _computePersons(List<KhataEntry> entries) {
    final Map<String, List<KhataEntry>> grouped = {};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.personName, () => []).add(entry);
    }

    return grouped.entries.map((e) {
      final name = e.key;
      final personEntries = e.value;
      final phone = personEntries
          .where((e) => e.phone != null && e.phone!.isNotEmpty)
          .firstOrNull
          ?.phone;

      int balance = 0;
      bool hasOverdueLent = false;
      bool hasOverdueBorrowed = false;
      DateTime? nearestDueDate;

      for (final entry in personEntries) {
        balance += entry.netEffect;

        if (entry.dueDate != null) {
          if (nearestDueDate == null ||
              entry.dueDate!.isBefore(nearestDueDate)) {
            nearestDueDate = entry.dueDate;
          }
          if (entry.type == EntryType.lent && entry.isOverdue) {
            hasOverdueLent = true;
          }
          if (entry.type == EntryType.borrowed && entry.isOverdue) {
            hasOverdueBorrowed = true;
          }
        }
      }

      final isOverdue = (balance > 0 && hasOverdueLent) ||
          (balance < 0 && hasOverdueBorrowed);

      return PersonSummary(
        name: name,
        phone: phone,
        balance: balance,
        entries: personEntries,
        isOverdue: isOverdue,
        nearestDueDate: nearestDueDate,
      );
    }).toList()
      ..sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
  }

  Future<void> addEntry({
    required String personName,
    String? phone,
    required int amountMinor,
    required EntryType type,
    DateTime? dueDate,
    String? notes,
  }) async {
    if (personName.trim().isEmpty) {
      state = state.copyWith(error: 'Enter a person name');
      return;
    }
    if (amountMinor <= 0) {
      state = state.copyWith(error: 'Enter a valid amount');
      return;
    }

    state = state.copyWith(clearError: true);

    await _repository.save(KhataEntry(
      personName: personName.trim(),
      phone: phone?.trim(),
      amountMinor: amountMinor,
      type: type,
      dateUtc: DateTime.now().toUtc(),
      dueDate: dueDate,
      notes: notes?.trim(),
    ));
  }

  Future<void> deleteEntry(int id) async {
    await _repository.delete(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
