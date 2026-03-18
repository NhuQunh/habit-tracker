import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/services/firebase_service.dart';
import 'package:habit_tracker/services/habit_service.dart';
import 'package:habit_tracker/services/localization_service.dart';
import 'package:habit_tracker/services/notification_service.dart';

enum HabitFilter { all, completedToday, notCompleted, longestStreak }

class HabitController extends ChangeNotifier {
  HabitController() {
    _activeUserId = _auth.currentUser?.uid;
    _authSubscription = _auth.authStateChanges().listen((user) async {
      final nextUserId = user?.uid;
      if (_activeUserId == nextUserId) {
        return;
      }
      _activeUserId = nextUserId;
      await initialize();
    });
    initialize();
  }

  final HabitService _habitService = HabitService();
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<Habit>>? _cloudHabitsSubscription;
  String? _activeUserId;
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

    try {
      _habits = await _habitService.loadHabits(userId: _activeUserId);
      if (_activeUserId != null) {
        try {
          await _migrateLocalHabitsIfNeeded(_activeUserId!);
          await _refreshHabitsFromCloud(_activeUserId!);
          _listenCloudHabits(_activeUserId!);
        } catch (error, stackTrace) {
          debugPrint('Cloud sync init failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
      } else {
        await _cloudHabitsSubscription?.cancel();
        _cloudHabitsSubscription = null;
      }

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
        await _persistHabits();
      }
    } catch (error, stackTrace) {
      debugPrint('Habit initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    try {
      // Check if we should send weekly report (every Sunday)
      await _checkAndSendWeeklyReport();
    } catch (_) {
      // Keep startup resilient even if notifications are unavailable.
    }
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

  String filterLabel(HabitFilter filter, AppLanguage language) {
    switch (filter) {
      case HabitFilter.all:
        return LocalizationService.translate('all', language);
      case HabitFilter.completedToday:
        return LocalizationService.translate('completed_today', language);
      case HabitFilter.notCompleted:
        return LocalizationService.translate('not_completed', language);
      case HabitFilter.longestStreak:
        return LocalizationService.translate('longest_streak', language);
    }
  }

  Future<void> addHabit(Habit habit) async {
    _habits = [habit, ..._habits];
    notifyListeners();
    await _persistHabits();
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
    await _persistHabits();
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
    await _persistHabits();
  }

  Future<void> deleteHabit(String id) async {
    _habits.removeWhere((habit) => habit.id == id);
    notifyListeners();
    await _persistHabits();
  }

  Future<void> _migrateLocalHabitsIfNeeded(String userId) async {
    final migrationDone = await _habitService.isFirestoreMigrationDone(userId);
    if (migrationDone) {
      return;
    }

    final hasPersistedLocalData = await _habitService.hasPersistedLocalHabits(
      userId: userId,
    );
    if (!hasPersistedLocalData) {
      await _habitService.markFirestoreMigrationDone(userId);
      return;
    }

    final cloudHabits = await _firebaseService.getHabits(userId);
    if (cloudHabits.isEmpty) {
      final localHabits = await _habitService.loadLocalHabitsOrEmpty(
        userId: userId,
      );
      if (localHabits.isNotEmpty) {
        await _firebaseService.setHabits(userId, localHabits);
      }
    }

    await _habitService.markFirestoreMigrationDone(userId);
  }

  Future<void> _refreshHabitsFromCloud(String userId) async {
    final cloudOrCachedHabits = await _firebaseService.getHabitsWithLocalFallback(
      userId,
      _habits,
    );
    _habits = cloudOrCachedHabits;
    await _habitService.saveHabits(_habits, userId: userId);
  }

  void _listenCloudHabits(String userId) {
    _cloudHabitsSubscription?.cancel();
    _cloudHabitsSubscription = _firebaseService.watchHabits(userId).listen((
      cloudHabits,
    ) {
      if (_sameHabitsState(_habits, cloudHabits)) {
        return;
      }

      _habits = cloudHabits;
      _habitService.saveHabits(_habits, userId: userId);
      notifyListeners();
    }, onError: (_) {
      // Continue using local data until Firestore stream recovers.
    });
  }

  bool _sameHabitsState(List<Habit> first, List<Habit> second) {
    if (first.length != second.length) {
      return false;
    }

    for (var i = 0; i < first.length; i++) {
      if (!mapEquals(first[i].toJson(), second[i].toJson())) {
        return false;
      }
    }

    return true;
  }

  Future<void> _persistHabits() async {
    await _habitService.saveHabits(_habits, userId: _activeUserId);

    final userId = _activeUserId;
    if (userId == null) {
      return;
    }

    try {
      await _firebaseService.setHabits(userId, _habits);
    } catch (_) {
      // Local cache is the source of truth while offline.
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cloudHabitsSubscription?.cancel();
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

  /// Calculate weekly statistics for habit completion
  Map<String, dynamic> calculateWeeklyStats() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = startOfWeek.add(const Duration(days: 6)); // Sunday

    int totalHabits = _habits.length;
    int totalCompletions = 0;
    int daysInWeek = 0;

    // Count days that have at least one completion this week
    final weekDays = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      if (day.isBefore(now) || _isSameDate(day, now)) {
        weekDays.add(day);
      }
    }
    daysInWeek = weekDays.length;

    // Count total completions this week
    for (final habit in _habits) {
      for (final completionDate in habit.completionDates) {
        if (completionDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            completionDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
          totalCompletions++;
        }
      }
    }

    // Calculate completion rate
    double completionRate = 0.0;
    if (totalHabits > 0 && daysInWeek > 0) {
      completionRate = totalCompletions / (totalHabits * daysInWeek);
      completionRate = completionRate.clamp(0.0, 1.0);
    }

    return {
      'totalHabits': totalHabits,
      'totalCompletions': totalCompletions,
      'daysInWeek': daysInWeek,
      'completionRate': completionRate,
      'completedHabits': _habits.where((h) => h.completedToday).length,
    };
  }

  /// Send weekly report notification if enabled
  Future<void> sendWeeklyReportIfEnabled() async {
    // Check if week summary is enabled in settings
    final prefs = await _habitService.getSharedPreferences();
    final isWeekSummaryEnabled = prefs.getBool('week_summary_enabled') ?? true;

    if (!isWeekSummaryEnabled) {
      return;
    }

    final stats = calculateWeeklyStats();
    final notificationService = NotificationService();

    await notificationService.showWeeklyReport(
      totalHabits: stats['totalHabits'] as int,
      completedHabits: stats['completedHabits'] as int,
      completionRate: stats['completionRate'] as double,
    );
  }

  /// Check if we should send weekly report (every Sunday)
  Future<void> _checkAndSendWeeklyReport() async {
    final now = DateTime.now();
    final prefs = await _habitService.getSharedPreferences();
    final lastReportKey = 'last_weekly_report_date';
    final lastReportDateStr = prefs.getString(lastReportKey);

    // Check if today is Sunday and we haven't sent report yet today
    if (now.weekday != DateTime.sunday) {
      return;
    }

    final todayStr = '${now.year}-${now.month}-${now.day}';
    if (lastReportDateStr == todayStr) {
      // Already sent report today
      return;
    }

    // Send weekly report
    await sendWeeklyReportIfEnabled();

    // Mark as sent today
    await prefs.setString(lastReportKey, todayStr);
  }
}
