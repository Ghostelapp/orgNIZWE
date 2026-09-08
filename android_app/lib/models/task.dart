import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  TaskPriority priority;
  DateTime? dueDate;
  DateTime? reminderDate;
  String category;
  List<Subtask> subtasks;
  bool isRecurring;
  String? recurrenceRule;
  DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.reminderDate,
    this.category = 'Ogólne',
    List<Subtask>? subtasks,
    this.isRecurring = false,
    this.recurrenceRule,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        subtasks = subtasks ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isCompleted': isCompleted ? 1 : 0,
        'priority': priority.index,
        'dueDate': dueDate?.toIso8601String(),
        'reminderDate': reminderDate?.toIso8601String(),
        'category': category,
        'isRecurring': isRecurring ? 1 : 0,
        'recurrenceRule': recurrenceRule,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isCompleted: json['isCompleted'] == 1,
        priority: TaskPriority.values[json['priority'] ?? 1],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
        category: json['category'] ?? 'Ogólne',
        isRecurring: json['isRecurring'] == 1,
        recurrenceRule: json['recurrenceRule'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class Subtask {
  final String id;
  String title;
  bool isCompleted;

  Subtask({String? id, required this.title, this.isCompleted = false})
      : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted ? 1 : 0,
      };

  factory Subtask.fromJson(Map<String, dynamic> json) => Subtask(
        id: json['id'],
        title: json['title'],
        isCompleted: json['isCompleted'] == 1,
      );
}
