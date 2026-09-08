import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  String title;
  String iconName;
  String colorHex;
  int targetCount;
  String unit;
  List<DateTime> completedDates;
  DateTime createdAt;

  Habit({
    String? id,
    required this.title,
    this.iconName = 'water_drop',
    this.colorHex = '#6366F1',
    this.targetCount = 1,
    this.unit = 'raz',
    List<DateTime>? completedDates,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        completedDates = completedDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  double get weeklyProgress {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int completedThisWeek = 0;
    for (var date in completedDates) {
      if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(now.add(const Duration(days: 1)))) {
        completedThisWeek++;
      }
    }
    return completedThisWeek / targetCount;
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final wasCompleted = completedDates.any((d) =>
          d.year == date.year && d.month == date.month && d.day == date.day);
      if (wasCompleted) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'iconName': iconName,
        'colorHex': colorHex,
        'targetCount': targetCount,
        'unit': unit,
        'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'],
        title: json['title'],
        iconName: json['iconName'] ?? 'water_drop',
        colorHex: json['colorHex'] ?? '#6366F1',
        targetCount: json['targetCount'] ?? 1,
        unit: json['unit'] ?? 'raz',
        completedDates: (json['completedDates'] as List<dynamic>?)
                ?.map((d) => DateTime.parse(d as String))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
