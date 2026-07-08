import 'package:flutter/material.dart';

import '../../core/theme.dart';

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
          _infoTile(Icons.code, 'Developer', 'ClearSpend Team'),
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
              'ClearSpend is an offline-first personal finance manager. '
              'All your financial data is stored securely on your device. '
              'No accounts, no cloud, no tracking.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _sectionHeader('Device Info'),
          _infoTile(Icons.phone_android, 'Platform', 'Android / iOS'),
          _infoTile(Icons.sd_storage, 'OS Version', 'Android 14 / iOS 18'),
          _infoTile(Icons.memory, 'Flutter', '3.29.2'),
          _infoTile(Icons.web_asset, 'Dart SDK', '3.7.2'),
          _infoTile(Icons.smart_toy, 'Architecture', 'arm64-v8a'),
          const SizedBox(height: 32),
          _sectionHeader('Changelog'),
          _changelogCard(
            version: '1.0.0',
            date: '2026-06-15',
            notes: [
              'Initial public release',
              'Offline-first architecture with local SQLite storage',
              'Transaction tracking with categories and tags',
              'Budget management with monthly rollovers',
              'Interactive charts and spending insights',
              'Multi-currency support with live exchange rates',
              'Dark theme with Material You design language',
              'CSV import and export functionality',
              'Biometric authentication support',
              'Recurring transaction scheduling',
            ],
            isLatest: true,
          ),
          _versionCard(
            version: '0.9.0',
            date: '2026-05-20',
            notes: [
              'Beta release for internal testing',
              'Complete budget engine implementation',
              'Category management with custom icons',
              'Search and filter transactions',
            ],
          ),
          _versionCard(
            version: '0.8.0',
            date: '2026-04-10',
            notes: [
              'Added basic transaction CRUD operations',
              'Dashboard with summary widgets',
              'Settings screen with theme toggle',
              'Localization foundation (en, es, fr)',
            ],
          ),
          _versionCard(
            version: '0.7.0',
            date: '2026-03-01',
            notes: [
              'Project scaffolding and architecture setup',
              'SQLite schema design and repository layer',
              'State management with Riverpod',
              'Initial UI component library (AppTheme)',
            ],
          ),
          const SizedBox(height: 32),
          _sectionHeader('Tech Stack'),
          _techStackCard(),
          const SizedBox(height: 32),
          _sectionHeader('Open Source Licenses'),
          _licenseTile('Flutter', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('Dart SDK', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('Dart Frog Backend', 'MIT', 'Very Good Ventures'),
          _licenseTile('Riverpod', 'MIT', 'Remi Rousselet'),
          _licenseTile('Drift (SQLite ORM)', 'MIT', 'Simen B.  and the Drift team'),
          _licenseTile('Flutter Charts (FL Chart)', 'MIT', 'imaNNeo'),
          _licenseTile('GoRouter', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('Google Fonts', 'Apache 2.0', 'Google LLC'),
          _licenseTile('intl (Localization)', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('url_launcher', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('share_plus', 'BSD 3-Clause', 'Flutter Community'),
          _licenseTile('path_provider', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('flutter_secure_storage', 'BSD 3-Clause', 'German Saprykin'),
          _licenseTile('local_auth', 'BSD 3-Clause', 'Google LLC'),
          _licenseTile('csv', 'MIT', 'Zachary Dale'),
          const SizedBox(height: 32),
          _sectionHeader('Credits & Contributors'),
          _creditCard(
            'Rahul Sharma',
            'Lead Developer & Architect',
            'Core architecture, transaction engine, budget system',
          ),
          _creditCard(
            'Priya Patel',
            'UI/UX Designer',
            'Design system, dark theme, component library',
          ),
          _creditCard(
            'Alex Chen',
            'Mobile Engineer',
            'Charts, animations, performance optimization',
          ),
          _creditCard(
            'Maria Lopez',
            'QA Engineer',
            'Testing, bug triage, localization coordination',
          ),
          _creditCard(
            'James Wilson',
            'DevOps & Release',
            'CI/CD pipeline, code signing, Play Store management',
          ),
          _creditCard(
            'Community',
            'Translators & Testers',
            'Beta testing, translations, feature feedback',
          ),
          const SizedBox(height: 32),
          _sectionHeader('Support & FAQ'),
          _faqItem(
            question: 'How do I back up my data?',
            answer:
                'Go to Settings > Backup & Restore. You can export your data as a CSV file '
                'or create a full SQLite backup. Backups are stored locally — transfer them '
                'manually to another device.',
          ),
          _faqItem(
            question: 'Is my data synced across devices?',
            answer:
                'No. ClearSpend is fully offline-first. Your data never leaves your device. '
                'To move data between devices, use the backup/restore feature.',
          ),
          _faqItem(
            question: 'Can I set a budget for multiple months?',
            answer:
                'Yes. Each budget runs on a monthly cycle. You can set a budget for any month '
                'and customize it per category. Unused budget does not roll over by default, '
                'but you can enable rollover in budget settings.',
          ),
          _faqItem(
            question: 'How do I delete all my data?',
            answer:
                'Navigate to Settings > Data Management > Delete All Data. This will '
                'permanently remove all transactions, budgets, and categories. This action '
                'cannot be undone.',
          ),
          _faqItem(
            question: 'Why does the app need biometric permission?',
            answer:
                'Biometric authentication (fingerprint / face ID) is optional. When enabled, '
                'it locks the app behind your device authentication. Your biometric data '
                'is never stored — the OS handles all verification.',
          ),
          _faqItem(
            question: 'How are exchange rates updated?',
            answer:
                'Exchange rates are fetched from a public API when you open the currency '
                'converter. Rates are cached locally for 24 hours. You can manually refresh '
                'at any time.',
          ),
          _faqItem(
            question: 'Can I export to PDF?',
            answer:
                'PDF export is available in the Pro version. You can generate statement-grade '
                'PDFs with your transactions, charts, and a cover page.',
          ),
          _faqItem(
            question: 'How do I report a bug?',
            answer:
                'Please open an issue on our GitHub repository or email support@fintrack.app. '
                'Include your device model, OS version, and steps to reproduce the issue.',
          ),
          const SizedBox(height: 48),
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
            'Flutter 3.29.2 \u2014 Cross-platform UI toolkit',
            'Dart 3.7.2 \u2014 Client-optimized language',
          ]),
          _techDivider(),
          _techCategory('State Management', [
            'Riverpod 2.6 \u2014 Compile-safe state management',
            'Flutter Hooks \u2014 Widget lifecycle utilities',
          ]),
          _techDivider(),
          _techCategory('Database & Storage', [
            'Drift (SQLite ORM) \u2014 Reactive local database',
            'SharedPreferences \u2014 Key-value settings store',
            'Secure Storage \u2014 Encrypted credential storage',
          ]),
          _techDivider(),
          _techCategory('UI & Charts', [
            'FL Chart \u2014 Interactive financial charts',
            'Google Fonts (Inter) \u2014 App typography',
            'Material You \u2014 Dynamic color adaptation',
          ]),
          _techDivider(),
          _techCategory('Networking', [
            'Dart Frog \u2014 Local backend server',
            'HTTP \u2014 API communication',
            'connectivity_plus \u2014 Network status detection',
          ]),
          _techDivider(),
          _techCategory('Navigation', [
            'GoRouter \u2014 Declarative routing',
            'Deep linking support',
          ]),
          _techDivider(),
          _techCategory('Utilities', [
            'intl \u2014 Internationalization & formatting',
            'path_provider \u2014 Platform file paths',
            'url_launcher \u2014 External URL handling',
            'share_plus \u2014 Platform share sheet',
            'file_picker \u2014 File selection dialog',
            'csv \u2014 CSV parsing/generation',
            'local_auth \u2014 Biometric authentication',
            'timeago \u2014 Relative date formatting',
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

  Widget _faqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withAlpha(80),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warningGlass,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    size: 16,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}