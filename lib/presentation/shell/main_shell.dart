import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/theme.dart';
import '../analysis/analysis_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../emis/emis_screen.dart';
import '../history/history_screen.dart';
import '../khata/khata_screen.dart';
import '../settings/settings_screen.dart';

class _TabInfo {
  final IconData icon;
  final String label;
  const _TabInfo(this.icon, this.label);
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>>
      _connectivitySubscription;
  late final PageController _pageController;

  static const List<Widget> _screens = [
    DashboardScreen(),
    _AnalyticsTab(),
    KhataScreen(),
    EmisScreen(),
    _MoreTab(),
  ];

  static const List<_TabInfo> _tabs = [
    _TabInfo(Icons.grid_view_rounded, 'Home'),
    _TabInfo(Icons.analytics_rounded, 'Analytics'),
    _TabInfo(Icons.book_rounded, 'Khata'),
    _TabInfo(Icons.calendar_month_rounded, 'EMIs'),
    _TabInfo(Icons.more_horiz_rounded, 'More'),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _initConnectivity();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
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
              style: TextStyle(
                  color: AppTheme.expense,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isSelected = i == _selectedIndex;
              final isCenter = i == 2;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _onTabChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withAlpha(20)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: isCenter
                              ? const EdgeInsets.all(10)
                              : EdgeInsets.zero,
                          decoration: isCenter
                              ? BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.primary.withAlpha(40),
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Icon(
                            tab.icon,
                            size: isCenter ? 24 : 22,
                            color: isCenter
                                ? Colors.white
                                : isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
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

// ── Analytics Tab (Charts + History merged) ──

class _AnalyticsTab extends ConsumerStatefulWidget {
  const _AnalyticsTab();
  @override
  ConsumerState<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<_AnalyticsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Charts'),
            Tab(text: 'Transactions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          const AnalysisBody(),
          const HistoryBody(),
        ],
      ),
    );
  }
}

// ── More Tab ──

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
