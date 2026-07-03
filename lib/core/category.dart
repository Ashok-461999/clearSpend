import 'package:flutter/material.dart';

enum CategoryType { expense, income }

enum Category {
  food,
  transport,
  shopping,
  utilities,
  entertainment,
  health,
  education,
  housing,
  other,
  salary,
  sports,
  freelance,
  otherIncome;

  CategoryType get type {
    switch (this) {
      case Category.salary:
      case Category.freelance:
      case Category.otherIncome:
        return CategoryType.income;
      default:
        return CategoryType.expense;
    }
  }

  bool get isIncome => type == CategoryType.income;

  String get label {
    switch (this) {
      case Category.food: return 'Food';
      case Category.transport: return 'Transport';
      case Category.shopping: return 'Shopping';
      case Category.utilities: return 'Utilities';
      case Category.entertainment: return 'Entertainment';
      case Category.health: return 'Health';
      case Category.education: return 'Education';
      case Category.housing: return 'Housing';
      case Category.other: return 'Other';
      case Category.salary: return 'Salary';
      case Category.sports: return 'Sports';
      case Category.freelance: return 'Freelance';
      case Category.otherIncome: return 'Other Income';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.food: return Icons.restaurant;
      case Category.transport: return Icons.directions_car;
      case Category.shopping: return Icons.shopping_bag;
      case Category.utilities: return Icons.flash_on;
      case Category.entertainment: return Icons.movie;
      case Category.health: return Icons.local_hospital;
      case Category.education: return Icons.school;
      case Category.housing: return Icons.home;
      case Category.other: return Icons.more_horiz;
      case Category.salary: return Icons.account_balance;
      case Category.sports: return Icons.sports_soccer;
      case Category.freelance: return Icons.work;
      case Category.otherIncome: return Icons.attach_money;
    }
  }

  Color get color {
    switch (this) {
      case Category.food: return const Color(0xFFFF6B6B);
      case Category.transport: return const Color(0xFF4ECDC4);
      case Category.shopping: return const Color(0xFFFF8A65);
      case Category.utilities: return const Color(0xFFFFD93D);
      case Category.entertainment: return const Color(0xFFA66CFF);
      case Category.health: return const Color(0xFF6BCB77);
      case Category.education: return const Color(0xFF4D96FF);
      case Category.housing: return const Color(0xFF7C3AED);
      case Category.other: return const Color(0xFF94A3B8);
      case Category.salary: return const Color(0xFF22C55E);
      case Category.sports: return const Color(0xFFFF6B35);
      case Category.freelance: return const Color(0xFF36A2EB);
      case Category.otherIncome: return const Color(0xFFA8E6CF);
    }
  }

  bool get isEssential {
    switch (this) {
      case Category.food:
      case Category.housing:
      case Category.utilities:
      case Category.health:
      case Category.transport:
      case Category.education:
        return true;
      case Category.shopping:
      case Category.entertainment:
      case Category.other:
      case Category.salary:
      case Category.sports:
      case Category.freelance:
      case Category.otherIncome:
        return false;
    }
  }
}
