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

    final shouldReset = await _habitService.shouldResetCompletedForNewDay();
    if (shouldReset) {
      for (final habit in _habits) {
        habit.completedToday = false;
      }
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

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
