import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:provider/provider.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  void _goToPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  String _monthLabel(DateTime date) {
    return 'Tháng ${date.month}/${date.year}';
  }

  Future<void> _toggleCompletion(bool value) async {
    await context.read<HabitProvider>().toggleHabitCompletion(
      widget.habitId,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitProvider>().habitById(widget.habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thói quen')),
        body: const Center(child: Text('Không tìm thấy thói quen')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(habit.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HabitSummaryCard(habit: habit, onChanged: _toggleCompletion),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CompletionCalendar(
                visibleMonth: _visibleMonth,
                completionDates: habit.completionDates,
                onPreviousMonth: _goToPreviousMonth,
                onNextMonth: _goToNextMonth,
                monthLabel: _monthLabel(_visibleMonth),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitSummaryCard extends StatelessWidget {
  const _HabitSummaryCard({required this.habit, required this.onChanged});

  final Habit habit;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: habit.completedToday
          ? Colors.green.withValues(alpha: 0.12)
          : Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              habit.category,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${habit.streak} ngày streak',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Số ngày đã hoàn thành: ${habit.completionDates.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: habit.completedToday,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                const SizedBox(width: 4),
                const Text('Đánh dấu hoàn thành hôm nay'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionCalendar extends StatelessWidget {
  const _CompletionCalendar({
    required this.visibleMonth,
    required this.completionDates,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.monthLabel,
  });

  final DateTime visibleMonth;
  final List<DateTime> completionDates;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final String monthLabel;

  static const List<String> _weekdayLabels = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  Set<DateTime> get _completedDaySet {
    return completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final firstWeekdayIndex = firstDayOfMonth.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );

    final dayCells = <Widget>[];

    for (var i = 0; i < firstWeekdayIndex; i++) {
      dayCells.add(const SizedBox.shrink());
    }

    final completedDaySet = _completedDaySet;
    final today = Habit.normalizeDate(DateTime.now());

    for (var day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(visibleMonth.year, visibleMonth.month, day);
      final normalizedCurrentDate = Habit.normalizeDate(currentDate);
      final isCompleted = completedDaySet.contains(normalizedCurrentDate);
      final isToday = DateUtils.isSameDay(normalizedCurrentDate, today);

      dayCells.add(
        _DayCell(dayNumber: day, isCompleted: isCompleted, isToday: isToday),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPreviousMonth,
              icon: const Icon(Icons.chevron_left_rounded),
              tooltip: 'Tháng trước',
            ),
            Expanded(
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: const Icon(Icons.chevron_right_rounded),
              tooltip: 'Tháng sau',
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _weekdayLabels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.8,
          ),
          itemBuilder: (context, index) {
            return Center(
              child: Text(
                _weekdayLabels[index],
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dayCells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          itemBuilder: (context, index) => dayCells[index],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 8),
            const Text('Ngày đã hoàn thành'),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dayNumber,
    required this.isCompleted,
    required this.isToday,
  });

  final int dayNumber;
  final bool isCompleted;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.88)
            : Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: isToday ? 1.5 : 0.8,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$dayNumber',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isCompleted
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isCompleted)
            const Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
