import 'dart:convert';

import '../../core/category.dart';

class Goal {
  final int? id;
  final String name;
  final int targetAmount; // paise
  final int currentAmount; // paise
  final DateTime deadline;
  final Category? category;

  const Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.deadline,
    this.category,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;

  int get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  int get daysRemaining =>
      deadline.difference(DateTime.now()).inDays.clamp(0, 99999);

  int get monthlyTarget {
    if (daysRemaining <= 0 || remaining <= 0) return 0;
    final months = (daysRemaining / 30).ceil().clamp(1, 999);
    return (remaining / months).round();
  }

  Goal copyWith({
    int? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    DateTime? deadline,
    Category? category,
    bool clearId = false,
  }) {
    return Goal(
      id: clearId ? null : (id ?? this.id),
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline.toIso8601String(),
        'categoryIndex': category?.index,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as int?,
        name: json['name'] as String,
        targetAmount: json['targetAmount'] as int,
        currentAmount: json['currentAmount'] as int? ?? 0,
        deadline: DateTime.parse(json['deadline'] as String),
        category: json['categoryIndex'] != null
            ? Category.values[json['categoryIndex'] as int]
            : null,
      );

  String toJsonString() => jsonEncode(toJson());

  factory Goal.fromJsonString(String s) =>
      Goal.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
