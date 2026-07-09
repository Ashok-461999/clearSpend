import 'package:flutter/material.dart';

import '../../core/theme.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(25),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'ClearSpend',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionHeader('App Info'),
          _infoTile(Icons.code, 'Developer', 'Ashok'),
          _infoTile(Icons.email, 'Email', 'ashok.dev.engineer@gmail.com'),
          _infoTile(Icons.update, 'Build', '1.0.0+1'),
          _infoTile(Icons.storage, 'Data', 'Stored locally on device'),
          _infoTile(Icons.security, 'Privacy', 'No data shared externally'),
          const SizedBox(height: 32),
          _sectionHeader('About ClearSpend'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface.withAlpha(120),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'ClearSpend is an offline-first personal finance tracker. '
              'Track expenses, manage budgets, set savings goals, and '
              'gain insights into your spending habits. All your data '
              'is stored securely on your device.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionHeader('Changelog'),
          _changelogCard(
            version: '1.0.0',
            date: '2026-07-01',
            notes: [
              'Initial public release',
              'Offline-first architecture with local storage',
              'Expense & income tracking with categories',
              'Budget management per category',
              'Savings goals with progress tracking',
              'Interactive charts and spending insights',
              'Multi-currency support',
              'Dark theme support',
              'CSV import and export',
              'Biometric authentication',
            ],
            isLatest: true,
          ),
          _versionCard(
            version: '0.9.0',
            date: '2026-06-01',
            notes: [
              'Beta release',
              'Complete budget engine',
              'Category management',
              'Search and filter transactions',
              'Goal contribution tracking',
            ],
          ),
          const SizedBox(height: 32),
          _sectionHeader('Open Source Licenses'),
          _licenseTile('Flutter', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('Dart SDK', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('Riverpod', 'MIT', 'Remi Rousselet'),
          _licenseTile('Isar', 'Apache 2.0', 'Isar Community'),
          _licenseTile('Hive', 'MIT', 'Hive Community'),
          _licenseTile('FL Chart', 'MIT', 'imaNNeo'),
          _licenseTile('Google Fonts', 'Apache 2.0', 'Google LLC'),
          _licenseTile('intl', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('share_plus', 'BSD 3-Clause', 'Flutter Community'),
          _licenseTile('path_provider', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('local_auth', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('csv', 'MIT', 'Zachary Dale'),
          const SizedBox(height: 32),
          _sectionHeader('Credits'),
          _creditCard(
            'Ashok',
            'Developer',
            'Built with Flutter & Riverpod. Architecture, UI, and all features.',
          ),
          const SizedBox(height: 48),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen()),
              ),
              icon: const Icon(Icons.shield_outlined, size: 16),
              label: const Text('Privacy Policy'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Made with Flutter  \u2665  ClearSpend 2026',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withAlpha(150),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentGlass,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _changelogCard({
    required String version,
    required String date,
    required List<String> notes,
    bool isLatest = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLatest
            ? AppTheme.primary.withAlpha(15)
            : AppTheme.cardSurface.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest ? AppTheme.primary.withAlpha(60) : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLatest
                      ? AppTheme.primary.withAlpha(30)
                      : AppTheme.accentGlass,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v$version',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isLatest ? AppTheme.primary : AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              if (isLatest) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warningGlass,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Latest',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          for (final note in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u2022',
                    style: TextStyle(
                      fontSize: 12,
                      color: isLatest ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _versionCard({
    required String version,
    required String date,
    required List<String> notes,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentGlass,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'v$version',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                for (final note in notes)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '\u2022 $note',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _techStackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _techCategory('Framework', [
            'Flutter 3.29.2 — Cross-platform UI toolkit',
            'Dart 3.7.2 — Client-optimized language',
          ]),
          _techDivider(),
          _techCategory('State Management', [
            'Riverpod 2.6 — Compile-safe state management',
          ]),
          _techDivider(),
          _techCategory('Database & Storage', [
            'Isar — High-performance local database',
            'Hive — Lightweight key-value store for budgets & goals',
            'SharedPreferences — User settings',
          ]),
          _techDivider(),
          _techCategory('UI & Charts', [
            'FL Chart — Interactive financial charts',
            'Google Fonts (Inter) — App typography',
          ]),
          _techDivider(),
          _techCategory('Utilities', [
            'intl — Formatting & localization',
            'path_provider — Platform file paths',
            'share_plus — Platform share sheet',
            'file_picker — File selection',
            'csv — CSV parsing/generation',
            'local_auth — Biometric authentication',
            'image_picker — Receipt photo capture',
            'mobile_scanner — QR code scanning',
            'flutter_contacts — Contacts integration',
          ]),
        ],
      ),
    );
  }

  Widget _techCategory(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 8),
            child: Text(
              '\u2022 $item',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _techDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: AppTheme.border,
        height: 1,
      ),
    );
  }

  Widget _licenseTile(String package, String license, String author) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGlass,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.article_outlined,
                size: 16,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$license by $author',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _creditCard(String name, String role, String contribution) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(120),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGlass,
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    contribution,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
