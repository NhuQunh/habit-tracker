import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/localization_provider.dart';
import 'package:provider/provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizationProvider = context.watch<LocalizationProvider>();

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
          ),
          const SizedBox(height: 8),
          Text(
            'Tong quan tien do habit trong tuan.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoan thanh 7 ngay gan nhat',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Bar(value: 0.65, label: 'T2'),
                    const _Bar(value: 0.8, label: 'T3'),
                    const _Bar(value: 0.45, label: 'T4'),
                    const _Bar(value: 0.9, label: 'T5'),
                    const _Bar(value: 0.7, label: 'T6'),
                    const _Bar(value: 0.5, label: 'T7'),
                    const _Bar(value: 0.85, label: 'CN'),
                    const Spacer(),
                    Text(
                      'Ty le trung binh: 69%',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: value,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
