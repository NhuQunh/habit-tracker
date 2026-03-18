import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/screens/habit_detail_screen.dart';
import 'package:habit_tracker/widgets/add_habit_dialog.dart';
import 'package:habit_tracker/widgets/habit_card.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    final habitController = context.read<HabitController>();
    final selected = await showModalBottomSheet<HabitFilter>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lọc danh sách',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...HabitFilter.values.map(
                  (filter) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      filter == habitController.selectedFilter
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                    ),
                    title: Text(habitController.filterLabel(filter)),
                    onTap: () {
                      Navigator.of(sheetContext).pop(filter);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    habitController.setFilter(selected);
  }

  IconData _habitIconFor(Habit habit) {
    const iconByKey = {
      'target': Icons.track_changes_rounded,
      'water': Icons.local_drink_rounded,
      'exercise': Icons.fitness_center_rounded,
      'book': Icons.menu_book_rounded,
      'meditate': Icons.self_improvement_rounded,
      'code': Icons.code_rounded,
      'alarm': Icons.alarm_rounded,
      'heart': Icons.favorite_rounded,
    };

    final customIcon = iconByKey[habit.iconKey];
    if (customIcon != null) {
      return customIcon;
    }

    final name = habit.name.toLowerCase();
    final category = habit.category.toLowerCase();

    if (name.contains('nuoc') || name.contains('nước')) {
      return Icons.local_drink_rounded;
    }
    if (name.contains('the duc') ||
        name.contains('thể dục') ||
        category.contains('van dong') ||
        category.contains('vận động')) {
      return Icons.fitness_center_rounded;
    }
    if (name.contains('sach') || name.contains('sách')) {
      return Icons.menu_book_rounded;
    }
    if (name.contains('thien') || name.contains('thiền')) {
      return Icons.self_improvement_rounded;
    }
    if (name.contains('flutter') ||
        category.contains('cong nghe') ||
        category.contains('công nghệ')) {
      return Icons.code_rounded;
    }

    return Icons.track_changes_rounded;
  }

  Color _categoryColorFor(Habit habit) {
    final category = habit.category.toLowerCase();

    if (category.contains('sức khỏe') || category.contains('suc khoe')) {
      return Colors.purple;
    }
    if (category.contains('học tập') || category.contains('hoc tap')) {
      return Colors.indigo;
    }
    if (category.contains('năng suất') || category.contains('nang suat')) {
      return Colors.teal;
    }
    if (category.contains('chánh niệm') ||
        category.contains('chanh niem') ||
        category.contains('tinh thần') ||
        category.contains('tinh than')) {
      return Colors.deepOrange;
    }
    if (category.contains('vận động') || category.contains('van dong')) {
      return Colors.redAccent;
    }
    if (category.contains('công nghệ') || category.contains('cong nghe')) {
      return Colors.blue;
    }

    return Colors.blueGrey;
  }

  Future<void> _showMilestoneDialog({
    required String habitName,
    required int streak,
  }) async {
    if (!mounted) {
      return;
    }

    final confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1200),
    );
    confettiController.play();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 120,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      ConfettiWidget(
                        confettiController: confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        emissionFrequency: 0.04,
                        numberOfParticles: 20,
                        maxBlastForce: 20,
                        minBlastForce: 8,
                        gravity: 0.2,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                          tooltip: 'Đóng',
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween(begin: 0.7, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: 110,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Chúc mừng!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$habitName đã đạt mốc $streak ngày streak!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );

    confettiController.dispose();
  }

  Future<void> _toggleHabitCompletion(String id, bool value) async {
    final milestoneHabit = await context
        .read<HabitController>()
        .toggleHabitCompletion(id, value);

    if (milestoneHabit == null) {
      return;
    }

    _showMilestoneDialog(
      habitName: milestoneHabit.name,
      streak: milestoneHabit.streak,
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa thói quen')));
  }

  @override
  Widget build(BuildContext context) {
    final habitController = context.watch<HabitController>();
    final habitsToShow = habitController.filteredHabits;
    final completedTodayCount = habitController.habits
        .where((habit) => habit.completedToday)
        .length;
    final totalHabits = habitController.habits.length;
    final completionRate = totalHabits == 0
        ? 0
        : ((completedTodayCount / totalHabits) * 100).round();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (habitController.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Thói quen của tôi - TH5 - G10'),
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _openFilterSheet,
            tooltip: 'Lọc danh sách',
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: isDarkMode
                ? 'Chuyển sang chế độ sáng'
                : 'Chuyển sang chế độ tối',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Duy trì thói quen mỗi ngày',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          label: 'Đã hoàn thành',
                          value: '$completedTodayCount/$totalHabits',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatPill(
                          label: 'Tỷ lệ hôm nay',
                          value: '$completionRate%',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên, danh mục, streak...',
                        prefixIcon: const Icon(Icons.search),
                        fillColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainer,
                      ),
                      onChanged: (value) {
                        habitController.setSearchQuery(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: habitsToShow.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 52,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Chưa có thói quen phù hợp bộ lọc',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Thử đổi bộ lọc hoặc thêm thói quen mới',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: habitsToShow.length,
                      itemBuilder: (context, index) {
                        final habit = habitsToShow[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HabitCard(
                            name: habit.name,
                            category: habit.category,
                            categoryColor: _categoryColorFor(habit),
                            habitIcon: _habitIconFor(habit),
                            streak: habit.streak,
                            completedToday: habit.completedToday,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      HabitDetailScreen(habitId: habit.id),
                                ),
                              );
                            },
                            onLongPress: () {
                              _confirmDeleteHabit(habit);
                            },
                            onChanged: (value) {
                              _toggleHabitCompletion(habit.id, value);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => const AddHabitDialog(),
          );
        },
        child: const Icon(Icons.add_task_rounded),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
