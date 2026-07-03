import 'package:flutter/material.dart';

import '../../core/money.dart';
import '../../core/theme.dart';

class AmountText extends StatelessWidget {
  final int minor;
  final double size;
  final bool isExpense;

  const AmountText({
    super.key,
    required this.minor,
    this.size = 16,
    this.isExpense = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      Money.format(minor),
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: isExpense ? AppTheme.expense : AppTheme.income,
        fontFeatures: const [FontFeature.tabularFigures()],
        letterSpacing: -0.3,
      ),
    );
  }
}
