// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/history/presentation/pages/history_page.dart';

class MainShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;
  const MainShell({super.key, required this.onToggleTheme, required this.isDark});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onToggleTheme: widget.onToggleTheme, isDark: widget.isDark),
      DashboardPage(onToggleTheme: widget.onToggleTheme, isDark: widget.isDark),
      const HistoryPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'สแกน',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'ประวัติ',
            ),
          ],
        ),
      ),
    );
  }
}
