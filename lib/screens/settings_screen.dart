import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/localization_provider.dart';
import 'package:habit_tracker/services/notification_service.dart';
import 'package:habit_tracker/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  bool _weekSummary = true;
  bool _darkMode = false;
  bool _isLoading = true;

  static const String _dailyReminderKey = 'daily_reminder_enabled';
  static const String _weekSummaryKey = 'week_summary_enabled';

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await _notificationService.initialize();
    } catch (_) {
      // Ignore plugin initialization errors in unsupported environments (e.g. widget tests).
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool(_dailyReminderKey) ?? true;
      _weekSummary = prefs.getBool(_weekSummaryKey) ?? true;
      _darkMode = prefs.getBool('theme_mode_dark') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dailyReminderKey, _dailyReminder);
    await prefs.setBool(_weekSummaryKey, _weekSummary);
  }

  Future<void> _toggleDailyReminder(bool value) async {
    setState(() {
      _dailyReminder = value;
    });

    try {
      if (value) {
        await _notificationService.scheduleDailyReminder();
      } else {
        await _notificationService.cancelDailyReminder();
      }
    } catch (_) {
      // Keep setting persisted even if notification plugin is unavailable.
    }

    await _saveSettings();
  }

  Future<void> _toggleWeekSummary(bool value) async {
    setState(() {
      _weekSummary = value;
    });
    await _saveSettings();
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });
    widget.onToggleTheme();
  }

  Future<void> _changeLanguage(AppLanguage language) async {
    final localizationProvider = context.read<LocalizationProvider>();
    await localizationProvider.setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationProvider = context.watch<LocalizationProvider>();

    if (_isLoading || localizationProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        Text(
          localizationProvider.translate('settings'),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizationProvider.translate('customize'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(localizationProvider.translate('dark_mode')),
                subtitle: Text(localizationProvider.translate('dark_mode_desc')),
                value: _darkMode,
                onChanged: _toggleDarkMode,
              ),
              const Divider(height: 0),
              ListTile(
                title: Text(localizationProvider.translate('language')),
                subtitle: Text(localizationProvider.translate('language_desc')),
                trailing: DropdownButton<AppLanguage>(
                  value: localizationProvider.currentLanguage,
                  items: [
                    DropdownMenuItem(
                      value: AppLanguage.english,
                      child: const Text('English'),
                    ),
                    DropdownMenuItem(
                      value: AppLanguage.vietnamese,
                      child: const Text('Tiếng Việt'),
                    ),
                  ],
                  onChanged: (AppLanguage? value) {
                    if (value != null) {
                      _changeLanguage(value);
                    }
                  },
                ),
              ),
              const Divider(height: 0),
              SwitchListTile(
                title: Text(localizationProvider.translate('daily_reminder')),
                subtitle: Text(localizationProvider.translate('daily_reminder_desc')),
                value: _dailyReminder,
                onChanged: _toggleDailyReminder,
              ),
              const Divider(height: 0),
              SwitchListTile(
                title: Text(localizationProvider.translate('weekly_report')),
                subtitle: Text(localizationProvider.translate('weekly_report_desc')),
                value: _weekSummary,
                onChanged: _toggleWeekSummary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(localizationProvider.translate('app_version')),
            subtitle: Text(localizationProvider.translate('version')),
          ),
        ),
      ],
    );
  }
}
