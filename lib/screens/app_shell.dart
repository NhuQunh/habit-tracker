import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/localization_provider.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/screens/settings_screen.dart';
import 'package:habit_tracker/screens/statistics_screen.dart';
import 'package:provider/provider.dart';

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
    final localizationProvider = context.watch<LocalizationProvider>();
    final tabs = [
      HomeScreen(onToggleTheme: widget.onToggleTheme),
      const StatisticsScreen(),
      SettingsScreen(onToggleTheme: widget.onToggleTheme),
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded),
              label: localizationProvider.translate('home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_rounded),
              label: localizationProvider.translate('stats'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: localizationProvider.translate('settings'),
            ),
          ],
        ),
      ),
    );
  }
}
