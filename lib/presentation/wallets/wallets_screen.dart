import 'package:flutter/material.dart';

import '../../core/theme.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WalletCard(
            name: 'Cash',
            balance: 0,
            icon: Icons.money,
            color: const Color(0xFF22C55E),
          ),
          const SizedBox(height: 12),
          _WalletCard(
            name: 'Bank Account',
            balance: 0,
            icon: Icons.account_balance,
            color: const Color(0xFF14B8A6),
          ),
          const SizedBox(height: 12),
          _WalletCard(
            name: 'Credit Card',
            balance: 0,
            icon: Icons.credit_card,
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final String name;
  final int balance;
  final IconData icon;
  final Color color;

  const _WalletCard({
    required this.name,
    required this.balance,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(200),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('₹ 0.00',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
