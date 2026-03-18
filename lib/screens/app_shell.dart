import 'package:flutter/material.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/screens/statistics_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const Color _selectedColor = Color(0xFF0EA5E9);

  int _currentIndex = 0;

  void _onTapNavItem(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeScreen(onToggleTheme: widget.onToggleTheme),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: tabs),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: _selectedColor.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              color: isSelected ? _selectedColor : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            );
          }),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTapNavItem,
          selectedItemColor: _selectedColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Trang chu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Thong ke',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Cai dat',
            ),
          ],
        ),
      ),
    );
  }
}
