import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  HabitProvider() {
    initialize();
  }

  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = true;

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;

  Habit? habitById(String id) {
    for (final habit in _habits) {
      if (habit.id == id) {
        return habit;
      }
    }
    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _habits = await _habitService.loadHabits();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    var hasChanges = false;

    for (final habit in _habits) {
      if (habit.lastStreakIncreaseDate == null && habit.streak > 0) {
        // Backfill old data so streak can be evaluated consistently.
        habit.lastStreakIncreaseDate = habit.completedToday
            ? todayDate
            : todayDate.subtract(const Duration(days: 1));
        hasChanges = true;
      }

      final lastDate = habit.lastStreakIncreaseDate;
      if (lastDate == null) {
        continue;
      }

      final normalizedLastDate = DateTime(
        lastDate.year,
        lastDate.month,
        lastDate.day,
      );
      final dayGap = todayDate.difference(normalizedLastDate).inDays;
      if (dayGap > 1 && habit.streak != 0) {
        habit.streak = 0;
        hasChanges = true;
      }
    }

    final shouldReset = await _habitService.shouldResetCompletedForNewDay();
    if (shouldReset) {
      for (final habit in _habits) {
        habit.completedToday = false;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _habitService.saveHabits(_habits);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addHabit(Habit habit) async {
    _habits = [habit, ..._habits];
    notifyListeners();
    await _habitService.saveHabits(_habits);
  }

  Future<Habit?> toggleHabitCompletion(String id, bool value) async {
    Habit? milestoneHabit;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final habit in _habits) {
      if (habit.id != id) {
        continue;
      }

      final previousStreak = habit.streak;

      if (value && !habit.completedToday) {
        final lastDate = habit.lastStreakIncreaseDate;
        if (lastDate != null) {
          final normalizedLastDate = DateTime(
            lastDate.year,
            lastDate.month,
            lastDate.day,
          );
          final dayGap = todayDate.difference(normalizedLastDate).inDays;

          if (dayGap > 1) {
            habit.streak = 0;
          }
        }

        habit.streak += 1;
        habit.lastStreakIncreaseDate = todayDate;
        if (!habit.completionDates.any(
          (date) => _isSameDate(date, todayDate),
        )) {
          habit.completionDates.add(todayDate);
        }
      }

      if (!value && habit.completedToday) {
        if (habit.streak > 0) {
          habit.streak -= 1;
        }
        if (habit.lastStreakIncreaseDate != null &&
            _isSameDate(habit.lastStreakIncreaseDate!, todayDate)) {
          habit.lastStreakIncreaseDate = null;
        }
        habit.completionDates.removeWhere(
          (date) => _isSameDate(date, todayDate),
        );
      }

      habit.completedToday = value;

      final reachedMilestone =
          value &&
          previousStreak > 0 &&
          previousStreak % 10 != 0 &&
          habit.streak % 10 == 0;
      if (reachedMilestone) {
        milestoneHabit = habit;
      }
      break;
    }

    notifyListeners();
    await _habitService.saveHabits(_habits);
    return milestoneHabit;
  }

  Future<void> updateHabitDetails({
    required String id,
    required String name,
    required String iconKey,
    String? reminderTime,
  }) async {
    for (final habit in _habits) {
      if (habit.id != id) {
        continue;
      }

      habit.name = name;
      habit.iconKey = iconKey;
      habit.reminderTime = reminderTime;
      break;
    }

    notifyListeners();
    await _habitService.saveHabits(_habits);
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
    await _habitService.saveHabits(_habits);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
