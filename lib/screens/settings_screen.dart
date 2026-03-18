import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _dailyReminder = true;
  bool _weekSummary = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      children: [
        Text(
          'Cai dat',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tuy chinh trai nghiem theo doi thoi quen.',
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
                title: const Text('Nhac nho hang ngay'),
                subtitle: const Text('Gui thong bao vao 7:00 moi sang'),
                value: _dailyReminder,
                onChanged: (value) {
                  setState(() {
                    _dailyReminder = value;
                  });
                },
              ),
              const Divider(height: 0),
              SwitchListTile(
                title: const Text('Bao cao cuoi tuan'),
                subtitle: const Text('Tong hop muc do hoan thanh habit'),
                value: _weekSummary,
                onChanged: (value) {
                  setState(() {
                    _weekSummary = value;
                  });
                },
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
          child: const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Phien ban ung dung'),
            subtitle: Text('1.0.0'),
          ),
        ),
      ],
    );
  }
}
