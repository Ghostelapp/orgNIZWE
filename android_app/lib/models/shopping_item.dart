import 'package:uuid/uuid.dart';

class ShoppingList {
  final String id;
  String name;
  List<ShoppingItem> items;
  DateTime createdAt;

  ShoppingList({
    String? id,
    required this.name,
    List<ShoppingItem>? items,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        items = items ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: json['id'],
        name: json['name'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}

class ShoppingItem {
  final String id;
  String name;
  String category;
  double quantity;
  String unit;
  bool isPurchased;

  ShoppingItem({
    String? id,
    required this.name,
    this.category = 'Inne',
    this.quantity = 1,
    this.unit = 'szt.',
    this.isPurchased = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'unit': unit,
        'isPurchased': isPurchased ? 1 : 0,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'],
        name: json['name'],
        category: json['category'] ?? 'Inne',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
        unit: json['unit'] ?? 'szt.',
        isPurchased: json['isPurchased'] == 1,
      );
}
