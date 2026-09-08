import 'package:uuid/uuid.dart';

enum NoteCategory { documents, importantDates, subscriptions, contacts, car, home, travel, goals, notes }

class LifeNote {
  final String id;
  String title;
  String content;
  NoteCategory category;
  DateTime createdAt;
  DateTime updatedAt;

  LifeNote({
    String? id,
    required this.title,
    this.content = '',
    this.category = NoteCategory.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'category': category.index,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory LifeNote.fromJson(Map<String, dynamic> json) => LifeNote(
        id: json['id'],
        title: json['title'],
        content: json['content'] ?? '',
        category: NoteCategory.values[json['category'] ?? 8],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );
}
