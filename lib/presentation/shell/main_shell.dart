import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/theme.dart';
import '../analysis/analysis_screen.dart';
import '../budget/budget_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../emis/emis_screen.dart';
import '../history/history_screen.dart';
import '../khata/khata_screen.dart';
import '../settings/settings_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../shared/quick_expense_sheet.dart';

class _TabInfo {
  final IconData icon;
  final String label;
  final IconData activeIcon;
  final List<_SubAction> subActions;
  const _TabInfo(this.icon, this.label, this.activeIcon, this.subActions);
}

class _SubAction {
  final String title;
  final IconData icon;
  const _SubAction(this.title, this.icon);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late final PageController _pageController;

  static const List<Widget> _screens = [
    DashboardScreen(),
    AnalysisScreen(),
    HistoryScreen(),
    BudgetScreen(),
    KhataScreen(),
    EmisScreen(),
    SettingsScreen(),
  ];

  static const List<_TabInfo> _tabs = [
    _TabInfo(Icons.grid_view_rounded, 'Dashboard', Icons.dashboard_rounded, [
      _SubAction('Quick Overview', Icons.lightbulb_outline),
      _SubAction('Monthly Report', Icons.description_outlined),
    ]),
    _TabInfo(Icons.analytics_rounded, 'Analytics', Icons.trending_up_rounded, [
      _SubAction('Category Analysis', Icons.pie_chart_outline),
      _SubAction('Trends', Icons.show_chart_outlined),
    ]),
    _TabInfo(Icons.receipt_long_rounded, 'History', Icons.history_rounded, [
      _SubAction('All Transactions', Icons.list_alt_rounded),
      _SubAction('Search', Icons.search_rounded),
    ]),
    _TabInfo(Icons.pie_chart_rounded, 'Budgets', Icons.account_balance_wallet_rounded, [
      _SubAction('Create Budget', Icons.add_circle_outline),
      _SubAction('Manage Budgets', Icons.edit_note_rounded),
    ]),
    _TabInfo(Icons.book_rounded, 'Khata', Icons.people_outline_rounded, [
      _SubAction('New Entry', Icons.note_add_outlined),
      _SubAction('View All', Icons.view_list_rounded),
    ]),
    _TabInfo(Icons.calendar_month_rounded, 'EMIs', Icons.credit_card_rounded, [
      _SubAction('Add EMI', Icons.add_card_outlined),
      _SubAction('Upcoming', Icons.event_note_rounded),
    ]),
    _TabInfo(Icons.settings_rounded, 'Settings', Icons.tune_rounded, [
      _SubAction('Export Data', Icons.file_download_outlined),
      _SubAction('About', Icons.info_outline_rounded),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _onConnectivityChanged(result);
    } catch (_) {
      setState(() => _isOffline = false);
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    if (!mounted) return;
    setState(() => _isOffline = result.contains(ConnectivityResult.none));
  }

  void _onTabChanged(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _openGlobalSearch() {
    showSearch(context: context, delegate: _GlobalSearchDelegate());
  }

  void _showQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _QuickActionsSheet(),
    );
  }

  void _showNavSubActionsSheet(int index) {
    final tab = _tabs[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NavSubActionsSheet(tabName: tab.label, actions: tab.subActions),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.expense.withAlpha(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: AppTheme.expense),
          const SizedBox(width: 8),
          Text('You are offline. Some features may be unavailable.',
              style: TextStyle(color: AppTheme.expense, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openGlobalSearch,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 20, color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Text('Search expenses, contacts, trades...',
                    style: TextStyle(color: AppTheme.textSecondary.withAlpha(150), fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('\u2315', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          _quickAction(Icons.add_circle_outline, 'Quick\nExpense', () => _showQuickActionsSheet()),
          const SizedBox(width: 10),
          _quickAction(Icons.qr_code_scanner_rounded, 'Scan', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
          }),
          const SizedBox(width: 10),
          _quickAction(Icons.currency_rupee_rounded, 'Add\nEMI', () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmisScreen()));
          }),
          const SizedBox(width: 10),
          _quickAction(Icons.swap_horiz_rounded, 'Transfer', () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transfer feature coming soon'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppTheme.cardSurface,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: AppTheme.primary),
                const SizedBox(height: 4),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textSecondary, height: 1.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    const income = 125000.0;
    const expense = 78350.0;
    const balance = income - expense;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.cardSurface, AppTheme.bgSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Expanded(child: _summaryItem('Income', income, AppTheme.income, Icons.arrow_downward_rounded)),
            Container(width: 1, height: 32, color: AppTheme.border),
            Expanded(child: _summaryItem('Expense', expense, AppTheme.expense, Icons.arrow_upward_rounded)),
            Container(width: 1, height: 32, color: AppTheme.border),
            Expanded(
              child: _summaryItem('Balance', balance, balance >= 0 ? AppTheme.income : AppTheme.expense, Icons.account_balance_wallet_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 3),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Text('\u20B9${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isSelected = i == _selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabChanged(i),
                  onLongPress: () => _showNavSubActionsSheet(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withAlpha(20) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? tab.activeIcon : tab.icon,
                          size: 22,
                          color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_isOffline) _buildOfflineBanner(),
          _buildSearchBar(),
          _buildQuickActions(),
          _buildMonthlySummary(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

class _GlobalSearchDelegate extends SearchDelegate<String?> {
  _GlobalSearchDelegate() : super(searchFieldLabel: 'Search expenses, contacts, trades...');

  static final List<_SearchItem> _allItems = [
    _SearchItem('Grocery Store', '\u20B92,450', 'Expense', Icons.shopping_cart_outlined, AppTheme.expense),
    _SearchItem('Netflix Subscription', '\u20B9499', 'Expense', Icons.tv_outlined, AppTheme.expense),
    _SearchItem('Electricity Bill', '\u20B91,200', 'Expense', Icons.bolt_outlined, AppTheme.expense),
    _SearchItem('Salary Credit', '\u20B985,000', 'Income', Icons.account_balance_outlined, AppTheme.income),
    _SearchItem('Freelance Payment', '\u20B915,000', 'Income', Icons.work_outline, AppTheme.income),
    _SearchItem('Rahul Sharma', '+91-9876543210 \u2022 Khata: \u20B95,200', 'Contact', Icons.person_outline, AppTheme.accent),
    _SearchItem('Priya Patel', '+91-9876543211 \u2022 Khata: \u20B91,800', 'Contact', Icons.person_outline, AppTheme.accent),
    _SearchItem('Amit Verma', '+91-9876543212 \u2022 Khata: \u20B93,400', 'Contact', Icons.person_outline, AppTheme.accent),
    _SearchItem('Reliance Industries', '50 shares @ \u20B92,450', 'Trade', Icons.trending_up_rounded, AppTheme.warning),
    _SearchItem('TCS Ltd', '25 shares @ \u20B93,890', 'Trade', Icons.trending_up_rounded, AppTheme.warning),
    _SearchItem('HDFC Bank', '40 shares @ \u20B91,675', 'Trade', Icons.trending_up_rounded, AppTheme.warning),
    _SearchItem('Infosys', '30 shares @ \u20B91,420', 'Trade', Icons.trending_up_rounded, AppTheme.warning),
  ];

  static const _recentSearches = ['Electricity Bill', 'Rahul', 'Reliance'];

  List<_SearchItem> _filter(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allItems.where((item) =>
        item.title.toLowerCase().contains(q) || item.subtitle.toLowerCase().contains(q) || item.type.toLowerCase().contains(q)).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: AppTheme.bg,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Recent Searches',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ),
            ..._recentSearches.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () => query = s,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 10),
                          Text(s, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Quick Categories',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Expenses', 'Income', 'Contacts', 'Trades'].map((c) {
                return ActionChip(
                  label: Text(c, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
                  backgroundColor: AppTheme.cardSurface,
                  side: BorderSide(color: AppTheme.border),
                  onPressed: () => query = c.toLowerCase(),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    final results = _filter(query);
    if (results.isEmpty) {
      return Container(
        color: AppTheme.bg,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textSecondary),
              SizedBox(height: 12),
              Text('No results found',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      color: AppTheme.bg,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, i) {
          final item = results[i];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, size: 20, color: item.color),
            ),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 14)),
            subtitle: Text('${item.type} \u2022 ${item.subtitle}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.color.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(item.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: item.color)),
            ),
            onTap: () {
              close(context, item.title);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Selected: ${item.title}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppTheme.cardSurface,
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}

class _SearchItem {
  final String title;
  final String subtitle;
  final String type;
  final IconData icon;
  final Color color;
  const _SearchItem(this.title, this.subtitle, this.type, this.icon, this.color);
}

class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Quick Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                _actionTile(context, Icons.add_circle_outline, 'Quick\nExpense', AppTheme.expense, () {
                  Navigator.of(context).pop();
                  QuickExpenseSheet.show(context);
                }),
                const SizedBox(width: 12),
                _actionTile(context, Icons.qr_code_scanner_rounded, 'Scan\nReceipt', AppTheme.primary, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                }),
                const SizedBox(width: 12),
                _actionTile(context, Icons.currency_rupee_rounded, 'Add\nEMI', AppTheme.warning, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmisScreen()));
                }),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _actionTile(context, Icons.account_balance_outlined, 'Record\nIncome', AppTheme.income, () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Income form opened'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.cardSurface,
                    ),
                  );
                }),
                const SizedBox(width: 12),
                _actionTile(context, Icons.people_outline, 'Khata\nEntry', AppTheme.accent, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KhataScreen()));
                }),
                const SizedBox(width: 12),
                _actionTile(context, Icons.pie_chart_outline, 'View\nBudget', AppTheme.primary, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BudgetScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withAlpha(40)),
            ),
            child: Column(
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSubActionsSheet extends StatelessWidget {
  final String tabName;
  final List<_SubAction> actions;
  const _NavSubActionsSheet({required this.tabName, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(tabName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Quick actions for $tabName',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ...actions.map((action) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${action.title} selected'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppTheme.cardSurface,
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(action.icon, size: 18, color: AppTheme.primary),
                            ),
                            const SizedBox(width: 14),
                            Text(action.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded, size: 20, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
