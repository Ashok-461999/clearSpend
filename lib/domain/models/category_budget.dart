import 'dart:convert';

import '../../core/category.dart';

class CategoryBudget {
  final int? id;
  final Category category;
  final int monthlyLimit; // paise
  final int yearMonth; // YYYYMM, e.g. 202607

  const CategoryBudget({
    this.id,
    required this.category,
    required this.monthlyLimit,
    required this.yearMonth,
  });

  CategoryBudget copyWith({
    int? id,
    Category? category,
    int? monthlyLimit,
    int? yearMonth,
    bool clearId = false,
  }) {
    return CategoryBudget(
      id: clearId ? null : (id ?? this.id),
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      yearMonth: yearMonth ?? this.yearMonth,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryIndex': category.index,
        'monthlyLimit': monthlyLimit,
        'yearMonth': yearMonth,
      };

  factory CategoryBudget.fromJson(Map<String, dynamic> json) => CategoryBudget(
        id: json['id'] as int?,
        category: Category.values[json['categoryIndex'] as int],
        monthlyLimit: json['monthlyLimit'] as int,
        yearMonth: json['yearMonth'] as int,
      );

  String toJsonString() => jsonEncode(toJson());

  factory CategoryBudget.fromJsonString(String s) =>
      CategoryBudget.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
