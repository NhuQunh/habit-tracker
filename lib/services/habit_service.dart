import 'dart:convert';

import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitService {
  static const String _habitsKey = 'habits_data';
  static const String _lastOpenDateKey = 'last_open_date';
  static const String _migrationPrefix = 'habits_firestore_migrated_';
  static const Map<String, String> _habitNameViMap = {
    'Drink Water': 'Uống nước',
    'Uong nuoc': 'Uống nước',
    'Uống nước': 'Uống nước',
    'Exercise': 'Tập thể dục',
    'Tap the duc': 'Tập thể dục',
    'Tập thể dục': 'Tập thể dục',
    'Read Book': 'Đọc sách',
    'Doc sach': 'Đọc sách',
    'Đọc sách': 'Đọc sách',
    'Meditation': 'Thiền định',
    'Thien': 'Thiền định',
    'Thien dinh': 'Thiền định',
    'Thiền định': 'Thiền định',
    'Study Flutter': 'Học Flutter',
    'Hoc Flutter': 'Học Flutter',
    'Học Flutter': 'Học Flutter',
  };

  static const Map<String, String> _categoryViMap = {
    'Health': 'Sức khỏe',
    'Suc khoe': 'Sức khỏe',
    'Sức khỏe': 'Sức khỏe',
    'Fitness': 'Vận động',
    'Van dong': 'Vận động',
    'Vận động': 'Vận động',
    'Learning': 'Học tập',
    'Hoc tap': 'Học tập',
    'Học tập': 'Học tập',
    'Mindfulness': 'Tinh thần',
    'Tinh than': 'Tinh thần',
    'Tinh thần': 'Tinh thần',
    'Coding': 'Công nghệ',
    'Cong nghe': 'Công nghệ',
    'Công nghệ': 'Công nghệ',
  };

  Future<SharedPreferences> getSharedPreferences() async {
    return await SharedPreferences.getInstance();
  }

  String _habitsKeyForUser(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _habitsKey;
    }
    return '${_habitsKey}_$userId';
  }

  Future<List<Habit>> loadHabits({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _habitsKeyForUser(userId);
    final habitsString = prefs.getString(scopedKey);

    if (habitsString == null || habitsString.isEmpty) {
      if (userId != null && userId.isNotEmpty) {
        // New Google account starts from an empty habit list.
        return [];
      }
      return _defaultHabits();
    }

    final decoded = jsonDecode(habitsString) as List<dynamic>;
    final loadedHabits = decoded
        .map((item) => Habit.fromJson(item as Map<String, dynamic>))
        .toList();

    return _normalizeToVietnamese(loadedHabits);
  }

  Future<List<Habit>> loadLocalHabitsOrEmpty({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _habitsKeyForUser(userId);
    final habitsString = prefs.getString(scopedKey);

    if (habitsString == null || habitsString.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(habitsString) as List<dynamic>;
    final loadedHabits = decoded
        .map((item) => Habit.fromJson(item as Map<String, dynamic>))
        .toList();

    return _normalizeToVietnamese(loadedHabits);
  }

  Future<bool> hasPersistedLocalHabits({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedKey = _habitsKeyForUser(userId);
    final scopedHabits = prefs.getString(scopedKey);
    if (scopedHabits != null && scopedHabits.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<bool> isFirestoreMigrationDone(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_migrationPrefix$userId') ?? false;
  }

  Future<void> markFirestoreMigrationDone(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_migrationPrefix$userId', true);
  }

  Future<void> saveHabits(List<Habit> habits, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(habits.map((habit) => habit.toJson()).toList());
    await prefs.setString(_habitsKeyForUser(userId), encoded);
  }

  Future<bool> shouldResetCompletedForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dateKey(DateTime.now());
    final lastOpenDate = prefs.getString(_lastOpenDateKey);

    await prefs.setString(_lastOpenDateKey, todayKey);
    return lastOpenDate != null && lastOpenDate != todayKey;
  }

  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<Habit> _defaultHabits() {
    return [
      Habit(
        id: '1',
        name: 'Uống nước',
        streak: 6,
        completedToday: false,
        category: 'Sức khỏe',
      ),
      Habit(
        id: '2',
        name: 'Tập thể dục',
        streak: 12,
        completedToday: false,
        category: 'Vận động',
      ),
      Habit(
        id: '3',
        name: 'Đọc sách',
        streak: 4,
        completedToday: false,
        category: 'Học tập',
      ),
      Habit(
        id: '4',
        name: 'Thiền định',
        streak: 9,
        completedToday: false,
        category: 'Tinh thần',
      ),
      Habit(
        id: '5',
        name: 'Học Flutter',
        streak: 15,
        completedToday: false,
        category: 'Công nghệ',
      ),
    ];
  }

  List<Habit> _normalizeToVietnamese(List<Habit> habits) {
    return habits
        .map(
          (habit) => Habit(
            id: habit.id,
            name: _habitNameViMap[habit.name] ?? habit.name,
            streak: habit.streak,
            completedToday: habit.completedToday,
            category: _categoryViMap[habit.category] ?? habit.category,
            iconKey: habit.iconKey,
            reminderTime: habit.reminderTime,
            startDate: habit.startDate,
            lastStreakIncreaseDate: habit.lastStreakIncreaseDate,
            completionDates: habit.completionDates,
          ),
        )
        .toList();
  }
}
