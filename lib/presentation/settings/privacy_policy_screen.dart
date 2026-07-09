import 'package:flutter/material.dart';

import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withAlpha(25),
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Last updated: July 9, 2026',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _section('Your Data Stays on Your Device'),
          _body(
            'ClearSpend is an offline-first application. All your financial data — '
            'expenses, income, budgets, goals, transactions, and settings — '
            'is stored exclusively on your device. We do not operate any cloud '
            'servers, databases, or remote storage systems.',
          ),
          _body(
            'We never collect, transmit, or store your personal or financial '
            'information on any external server. Your data remains under your '
            'full control at all times.',
          ),
          const SizedBox(height: 24),
          _section('No Data Collection'),
          _body(
            'ClearSpend does not collect, track, or share any personal '
            'information, usage statistics, crash reports, or analytics data. '
            'There are no third-party analytics SDKs, tracking libraries, or '
            'advertising frameworks embedded in the app.',
          ),
          const SizedBox(height: 24),
          _section('Internet Permissions'),
          _body(
            'The app may request internet access solely for the following optional features:',
          ),
          _bullet('Currency exchange rate updates (if enabled)'),
          _bullet('QR code scanning for UPI payments'),
          _body(
            'No personal or financial data is transmitted during these operations. '
            'Exchange rates are fetched from public APIs without sending any '
            'identifying information.',
          ),
          const SizedBox(height: 24),
          _section('Biometric Authentication'),
          _body(
            'If you choose to enable biometric lock (fingerprint or face unlock), '
            'the authentication data is handled entirely by your device\'s native '
            'biometric API. ClearSpend never stores or transmits biometric data.',
          ),
          const SizedBox(height: 24),
          _section('Data Backup & Export'),
          _body(
            'ClearSpend provides CSV export and JSON backup features. These '
            'create local files on your device that you may choose to '
            'copy, share, or store elsewhere. Any data you share via these '
            'exports is your own responsibility.',
          ),
          _body(
            'We do not offer cloud backup. To protect your data, '
            'we recommend regularly exporting your data and storing it securely.',
          ),
          const SizedBox(height: 24),
          _section('Your Responsibility'),
          _body(
            'Since ClearSpend stores all data locally on your device:',
          ),
          _bullet('You are solely responsible for backing up your data.'),
          _bullet('If you uninstall the app, all data will be erased.'),
          _bullet('If you lose or reset your device, data cannot be recovered.'),
          _bullet('We recommend exporting a backup before uninstalling or resetting.'),
          const SizedBox(height: 24),
          _section('Third-Party Services'),
          _body(
            'ClearSpend does not integrate with any third-party services that '
            'process your financial data. The app operates entirely offline '
            'by default.',
          ),
          const SizedBox(height: 24),
          _section('Children\'s Privacy'),
          _body(
            'ClearSpend is not directed at children under 13. We do not '
            'collect any personal information from any user, including children.',
          ),
          const SizedBox(height: 24),
          _section('Changes to This Policy'),
          _body(
            'We may update this privacy policy from time to time. Changes '
            'will be reflected in the app with an updated "Last updated" date. '
            'Continued use of the app after changes constitutes acceptance '
            'of the updated policy.',
          ),
          const SizedBox(height: 24),
          _section('Contact'),
          _body(
            'If you have questions about this privacy policy or the app\'s '
            'data practices, please contact the developer:',
          ),
          _contactRow(Icons.person_outline, 'Ashok Kumar'),
          _contactRow(Icons.email_outlined, 'ashok@moneymate.app'),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.income.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.income.withAlpha(40)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppTheme.income),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your data, your device, your control.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.income,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _body(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  \u2022  ',
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.accentGlass,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.accent),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
