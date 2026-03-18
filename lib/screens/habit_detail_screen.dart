import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class _HabitIconOption {
  const _HabitIconOption({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _visibleMonth;

  static const List<_HabitIconOption> _iconOptions = [
    _HabitIconOption(
      key: 'target',
      icon: Icons.track_changes_rounded,
      label: 'Mục tiêu',
    ),
    _HabitIconOption(
      key: 'water',
      icon: Icons.local_drink_rounded,
      label: 'Nước',
    ),
    _HabitIconOption(
      key: 'exercise',
      icon: Icons.fitness_center_rounded,
      label: 'Tập luyện',
    ),
    _HabitIconOption(key: 'book', icon: Icons.menu_book_rounded, label: 'Sách'),
    _HabitIconOption(
      key: 'meditate',
      icon: Icons.self_improvement_rounded,
      label: 'Thiền',
    ),
    _HabitIconOption(key: 'code', icon: Icons.code_rounded, label: 'Code'),
    _HabitIconOption(
      key: 'alarm',
      icon: Icons.alarm_rounded,
      label: 'Nhắc nhở',
    ),
    _HabitIconOption(
      key: 'heart',
      icon: Icons.favorite_rounded,
      label: 'Sức khỏe',
    ),
  ];

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

  IconData _iconForKey(String key) {
    for (final option in _iconOptions) {
      if (option.key == key) {
        return option.icon;
      }
    }
    return Icons.track_changes_rounded;
  }

  String? _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) {
      return null;
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  TimeOfDay? _parseReminderTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts.first);
    final minute = int.tryParse(parts.last);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _showEditHabitDialog(Habit habit) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _EditHabitDialog(
          initialName: habit.name,
          initialIconKey: habit.iconKey,
          initialReminderTime: _parseReminderTime(habit.reminderTime),
          iconOptions: _iconOptions,
          onSave: (name, iconKey, reminderTime) async {
            await context.read<HabitController>().updateHabitDetails(
              id: habit.id,
              name: name,
              iconKey: iconKey,
              reminderTime: _formatTimeOfDay(reminderTime),
            );

            if (!mounted) {
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật thói quen')),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleCompletion(bool value) async {
    await context.read<HabitController>().toggleHabitCompletion(
      widget.habitId,
      value,
    );
  }

  Future<void> _confirmDeleteHabit(Habit habit) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa thói quen'),
          content: Text(
            'Bạn có chắc muốn xóa "${habit.name}" không? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await context.read<HabitController>().deleteHabit(habit.id);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa thói quen')));
  }

  @override
  Widget build(BuildContext context) {
    final habit = context.watch<HabitController>().habitById(widget.habitId);

    if (habit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết thói quen')),
        body: const Center(child: Text('Không tìm thấy thói quen')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            onPressed: () => _confirmDeleteHabit(habit),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Xóa thói quen',
          ),
          IconButton(
            onPressed: () => _showEditHabitDialog(habit),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Chỉnh sửa thói quen',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HabitSummaryCard(
            habit: habit,
            iconData: _iconForKey(habit.iconKey),
            onChanged: _toggleCompletion,
          ),
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
                streak: habit.streak,
                completedToday: habit.completedToday,
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
  const _HabitSummaryCard({
    required this.habit,
    required this.iconData,
    required this.onChanged,
  });

  final Habit habit;
  final IconData iconData;
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
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    iconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
              'Tổng số ngày hoàn thành: ${habit.streak}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              habit.reminderTime == null
                  ? 'Nhắc nhở: Chưa cài đặt'
                  : 'Nhắc nhở: ${habit.reminderTime}',
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

class _EditHabitDialog extends StatefulWidget {
  const _EditHabitDialog({
    required this.initialName,
    required this.initialIconKey,
    required this.initialReminderTime,
    required this.iconOptions,
    required this.onSave,
  });

  final String initialName;
  final String initialIconKey;
  final TimeOfDay? initialReminderTime;
  final List<_HabitIconOption> iconOptions;
  final Future<void> Function(
    String name,
    String iconKey,
    TimeOfDay? reminderTime,
  )
  onSave;

  @override
  State<_EditHabitDialog> createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<_EditHabitDialog> {
  late final TextEditingController _nameController;
  late String _selectedIconKey;
  TimeOfDay? _selectedReminderTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedIconKey = widget.initialIconKey;
    _selectedReminderTime = widget.initialReminderTime;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _displayReminder(TimeOfDay? time) {
    if (time == null) {
      return 'Chưa cài đặt';
    }
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickReminder() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedReminderTime = selected;
    });
  }

  Future<void> _save() async {
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onSave(trimmedName, _selectedIconKey, _selectedReminderTime);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa thói quen'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Tên thói quen',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Biểu tượng',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.iconOptions.map((option) {
                return ChoiceChip(
                  selected: _selectedIconKey == option.key,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(option.icon, size: 18),
                      const SizedBox(width: 6),
                      Text(option.label),
                    ],
                  ),
                  onSelected: (selected) {
                    if (!selected) {
                      return;
                    }
                    setState(() {
                      _selectedIconKey = option.key;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              'Nhắc nhở',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Giờ: ${_displayReminder(_selectedReminderTime)}',
                  ),
                ),
                TextButton.icon(
                  onPressed: _pickReminder,
                  icon: const Icon(Icons.access_time_rounded),
                  label: const Text('Chọn giờ'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _selectedReminderTime = null;
                  });
                },
                child: const Text('Xóa nhắc nhở'),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }
}

class _CompletionCalendar extends StatelessWidget {
  const _CompletionCalendar({
    required this.visibleMonth,
    required this.completionDates,
    required this.streak,
    required this.completedToday,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.monthLabel,
  });

  final DateTime visibleMonth;
  final List<DateTime> completionDates;
  final int streak;
  final bool completedToday;
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

  Set<DateTime> _estimatedStreakDaySet(DateTime today) {
    final dates = <DateTime>{};
    if (streak <= 0) {
      return dates;
    }

    final anchorDate = completedToday
        ? today
        : Habit.normalizeDate(today.subtract(const Duration(days: 1)));

    for (var i = 0; i < streak; i++) {
      dates.add(Habit.normalizeDate(anchorDate.subtract(Duration(days: i))));
    }

    return dates;
  }

  Set<DateTime> _completedDaySet(DateTime today) {
    final savedDates = completionDates
        .map((date) => DateTime(date.year, date.month, date.day))
        .toSet();
    return {...savedDates, ..._estimatedStreakDaySet(today)};
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

    final today = Habit.normalizeDate(DateTime.now());
    final completedDaySet = _completedDaySet(today);

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
