class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.streak,
    required this.completedToday,
    required this.category,
    DateTime? startDate,
    this.lastStreakIncreaseDate,
    List<DateTime>? completionDates,
  }) : startDate = startDate ?? DateTime.now(),
       completionDates = (completionDates ?? const [])
           .map(normalizeDate)
           .toList();

  final String id;
  final String name;
  int streak;
  bool completedToday;
  final String category;
  final DateTime startDate;
  DateTime? lastStreakIncreaseDate;
  final List<DateTime> completionDates;

  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      streak: json['streak'] as int,
      completedToday: json['completedToday'] as bool,
      category: json['category'] as String,
      startDate: json['startDate'] == null
          ? DateTime.now()
          : DateTime.parse(json['startDate'] as String),
      lastStreakIncreaseDate: json['lastStreakIncreaseDate'] == null
          ? null
          : DateTime.parse(json['lastStreakIncreaseDate'] as String),
      completionDates: (json['completionDates'] as List<dynamic>? ?? const [])
          .map((item) => normalizeDate(DateTime.parse(item as String)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streak': streak,
      'completedToday': completedToday,
      'category': category,
      'startDate': startDate.toIso8601String(),
      'lastStreakIncreaseDate': lastStreakIncreaseDate?.toIso8601String(),
      'completionDates': completionDates
          .map((date) => normalizeDate(date).toIso8601String())
          .toList(),
    };
  }
}
