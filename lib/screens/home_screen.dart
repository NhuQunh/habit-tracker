import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/habit_detail_screen.dart';
import 'package:habit_tracker/widgets/add_habit_dialog.dart';
import 'package:habit_tracker/widgets/habit_card.dart';
import 'package:provider/provider.dart';

enum HabitFilter {
  all,
  completedToday,
  notCompleted,
  longestStreak,
  newestStartDate,
  oldestStartDate,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  HabitFilter _selectedFilter = HabitFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd');
  }

  bool _matchesSearchQuery(Habit habit) {
    final query = _normalizeText(_searchQuery.trim());
    if (query.isEmpty) {
      return true;
    }

    final searchableFields = [
      habit.name,
      habit.category,
      habit.streak.toString(),
      '${habit.streak} ngày',
      _formatDate(habit.startDate),
      habit.completedToday ? 'đã hoàn thành' : 'chưa hoàn thành',
      habit.completedToday ? 'hoan thanh' : 'chua hoan thanh',
    ];

    return searchableFields
        .map(_normalizeText)
        .any((field) => field.contains(query));
  }

  List<Habit> _filteredHabits(List<Habit> allHabits) {
    var results = allHabits.where((habit) {
      final matchesSearch = _matchesSearchQuery(habit);

      switch (_selectedFilter) {
        case HabitFilter.completedToday:
          return matchesSearch && habit.completedToday;
        case HabitFilter.notCompleted:
          return matchesSearch && !habit.completedToday;
        case HabitFilter.longestStreak:
          return matchesSearch;
        case HabitFilter.newestStartDate:
          return matchesSearch;
        case HabitFilter.oldestStartDate:
          return matchesSearch;
        case HabitFilter.all:
          return matchesSearch;
      }
    }).toList();

    if (_selectedFilter == HabitFilter.longestStreak) {
      results.sort((a, b) => b.streak.compareTo(a.streak));
    }
    if (_selectedFilter == HabitFilter.newestStartDate) {
      results.sort((a, b) => b.startDate.compareTo(a.startDate));
    }
    if (_selectedFilter == HabitFilter.oldestStartDate) {
      results.sort((a, b) => a.startDate.compareTo(b.startDate));
    }

    return results;
  }

  String _filterLabel(HabitFilter filter) {
    switch (filter) {
      case HabitFilter.all:
        return 'Tất cả';
      case HabitFilter.completedToday:
        return 'Đã hoàn thành hôm nay';
      case HabitFilter.notCompleted:
        return 'Chưa hoàn thành';
      case HabitFilter.longestStreak:
        return 'Streak dài nhất';
      case HabitFilter.newestStartDate:
        return 'Ngày bắt đầu gần nhất';
      case HabitFilter.oldestStartDate:
        return 'Ngày bắt đầu cũ nhất';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
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
        .read<HabitProvider>()
        .toggleHabitCompletion(id, value);

    if (milestoneHabit == null) {
      return;
    }

    _showMilestoneDialog(
      habitName: milestoneHabit.name,
      streak: milestoneHabit.streak,
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habitsToShow = _filteredHabits(habitProvider.habits);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (habitProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Thói quen của tôi - TH5 - G10'),
        centerTitle: false,
        elevation: 0,
        actions: [
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
              padding: const EdgeInsets.all(12),
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
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duy trì thói quen mỗi ngày',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên, danh mục, streak, ngày...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<HabitFilter>(
              initialValue: _selectedFilter,
              decoration: InputDecoration(
                labelText: 'Lọc danh sách',
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: HabitFilter.values
                  .map(
                    (filter) => DropdownMenuItem<HabitFilter>(
                      value: filter,
                      child: Text(_filterLabel(filter)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedFilter = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: habitsToShow.length,
                itemBuilder: (context, index) {
                  final habit = habitsToShow[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: HabitCard(
                      name: habit.name,
                      category: habit.category,
                      categoryColor: _categoryColorFor(habit),
                      startDate: _formatDate(habit.startDate),
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
