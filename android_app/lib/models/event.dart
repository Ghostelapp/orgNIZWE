import 'package:uuid/uuid.dart';

class CalendarEvent {
  final String id;
  String title;
  DateTime startDate;
  DateTime endDate;
  String? location;
  String? notes;
  DateTime? reminderDate;
  bool isRecurring;
  String? recurrenceRule;
  String category;

  CalendarEvent({
    String? id,
    required this.title,
    required this.startDate,
    required this.endDate,
    this.location,
    this.notes,
    this.reminderDate,
    this.isRecurring = false,
    this.recurrenceRule,
    this.category = 'Spotkania',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'location': location,
        'notes': notes,
        'reminderDate': reminderDate?.toIso8601String(),
        'isRecurring': isRecurring ? 1 : 0,
        'recurrenceRule': recurrenceRule,
        'category': category,
      };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'],
        title: json['title'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        location: json['location'],
        notes: json['notes'],
        reminderDate: json['reminderDate'] != null ? DateTime.parse(json['reminderDate']) : null,
        isRecurring: json['isRecurring'] == 1,
        recurrenceRule: json['recurrenceRule'],
        category: json['category'] ?? 'Spotkania',
      );
}
