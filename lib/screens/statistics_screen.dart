import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/localization_provider.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';
import 'package:habit_tracker/widgets/progress_chart.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationProvider = context.watch<LocalizationProvider>();
    final habitController = context.watch<HabitController>();
    final stats = habitController.calculateWeeklyStats();
    final totalHabits = stats['totalHabits'] as int;
    final completionRate = (stats['completionRate'] as double) * 100;

    if (habitController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizationProvider.translate('statistics'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
              localizationProvider.translate('weekly_overview'),
          const SizedBox(height: 8),
          Text(
            'Tong quan tien do habit trong tuan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: localizationProvider.translate('total_habits'),
                    value: '$totalHabits',
                    icon: Icons.list_alt,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: localizationProvider.translate('completion_rate'),
                    value: '${completionRate.toStringAsFixed(0)}%',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ProgressChart(habits: habitController.habits),
              ),
            ),
          ],
        ),
      );
    }
  }

  class _SummaryCard extends StatelessWidget {
    const _SummaryCard({
      required this.title,
      required this.value,
      required this.icon,
      required this.color,
    });

    final String title;
    final String value;
    final IconData icon;
    final Color color;

    @override
    Widget build(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
>>>>>>> 35c3e14 (feat: Hoàn thiện UI màn hình Statistics và Biểu đồ Progress Chart chuẩn Clean Code)
          ),
        ],
      ),
}
=======
}
>>>>>>> 35c3e14 (feat: Hoàn thiện UI màn hình Statistics và Biểu đồ Progress Chart chuẩn Clean Code)
