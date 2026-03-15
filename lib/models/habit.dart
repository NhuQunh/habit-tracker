class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.streak,
    required this.completedToday,
    required this.category,
    DateTime? startDate,
    this.lastStreakIncreaseDate,
  }) : startDate = startDate ?? DateTime.now();

  final String id;
  final String name;
  int streak;
  bool completedToday;
  final String category;
  final DateTime startDate;
  DateTime? lastStreakIncreaseDate;

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
    };
  }
}
