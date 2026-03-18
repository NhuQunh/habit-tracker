import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/habit_service.dart';

enum HabitFilter { all, completedToday, notCompleted, longestStreak }

class HabitController extends ChangeNotifier {
  HabitController() {
    initialize();
  }

  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = true;
  HabitFilter _selectedFilter = HabitFilter.all;
  String _searchQuery = '';

  List<Habit> get habits => List.unmodifiable(_habits);
  bool get isLoading => _isLoading;
  HabitFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  List<Habit> get filteredHabits => _filteredHabits(_habits);

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

  void setSearchQuery(String value) {
    final normalized = value.trim();
    if (_searchQuery == normalized) {
      return;
    }
    _searchQuery = normalized;
    notifyListeners();
  }

  void setFilter(HabitFilter filter) {
    if (_selectedFilter == filter) {
      return;
    }
    _selectedFilter = filter;
    notifyListeners();
  }

  String filterLabel(HabitFilter filter) {
    switch (filter) {
      case HabitFilter.all:
        return 'Tất cả';
      case HabitFilter.completedToday:
        return 'Đã hoàn thành hôm nay';
      case HabitFilter.notCompleted:
        return 'Chưa hoàn thành';
      case HabitFilter.longestStreak:
        return 'Streak dài nhất';
    }
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
    final query = _normalizeText(_searchQuery);
    if (query.isEmpty) {
      return true;
    }

    final searchableFields = [
      habit.name,
      habit.category,
      habit.streak.toString(),
      '${habit.streak} ngày',
      habit.completedToday ? 'đã hoàn thành' : 'chưa hoàn thành',
      habit.completedToday ? 'hoan thanh' : 'chua hoan thanh',
    ];

    return searchableFields
        .map(_normalizeText)
        .any((field) => field.contains(query));
  }

  List<Habit> _filteredHabits(List<Habit> allHabits) {
    final results = allHabits.where((habit) {
      final matchesSearch = _matchesSearchQuery(habit);

      switch (_selectedFilter) {
        case HabitFilter.completedToday:
          return matchesSearch && habit.completedToday;
        case HabitFilter.notCompleted:
          return matchesSearch && !habit.completedToday;
        case HabitFilter.longestStreak:
          return matchesSearch;
        case HabitFilter.all:
          return matchesSearch;
      }
    }).toList();

    if (_selectedFilter == HabitFilter.longestStreak) {
      results.sort((a, b) => b.streak.compareTo(a.streak));
    }

    return results;
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
