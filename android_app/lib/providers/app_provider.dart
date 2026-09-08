import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/event.dart';
import '../models/habit.dart';
import '../models/shopping_item.dart';
import '../models/note.dart';

class AppProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<CalendarEvent> _events = [];
  List<Habit> _habits = [];
  List<ShoppingList> _shoppingLists = [];
  List<LifeNote> _notes = [];
  String _userName = '';
  TimeOfDay _dayStart = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _dayEnd = const TimeOfDay(hour: 22, minute: 0);
  bool _isDarkMode = false;

  List<Task> get tasks => _tasks;
  List<CalendarEvent> get events => _events;
  List<Habit> get habits => _habits;
  List<ShoppingList> get shoppingLists => _shoppingLists;
  List<LifeNote> get notes => _notes;
  String get userName => _userName;
  TimeOfDay get dayStart => _dayStart;
  TimeOfDay get dayEnd => _dayEnd;
  bool get isDarkMode => _isDarkMode;

  AppProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;

    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      _tasks = (jsonDecode(tasksJson) as List)
          .map((e) => Task.fromJson(e))
          .toList();
    }

    final eventsJson = prefs.getString('events');
    if (eventsJson != null) {
      _events = (jsonDecode(eventsJson) as List)
          .map((e) => CalendarEvent.fromJson(e))
          .toList();
    }

    final habitsJson = prefs.getString('habits');
    if (habitsJson != null) {
      _habits = (jsonDecode(habitsJson) as List)
          .map((e) => Habit.fromJson(e))
          .toList();
    }

    final shoppingJson = prefs.getString('shoppingLists');
    if (shoppingJson != null) {
      _shoppingLists = (jsonDecode(shoppingJson) as List)
          .map((e) => ShoppingList.fromJson(e))
          .toList();
    }

    final notesJson = prefs.getString('notes');
    if (notesJson != null) {
      _notes = (jsonDecode(notesJson) as List)
          .map((e) => LifeNote.fromJson(e))
          .toList();
    }

    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('events', jsonEncode(_events.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('habits', jsonEncode(_habits.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveShoppingLists() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shoppingLists', jsonEncode(_shoppingLists.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(_notes.map((e) => e.toJson()).toList()));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  void addEvent(CalendarEvent event) {
    _events.add(event);
    _saveEvents();
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    _saveEvents();
    notifyListeners();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void toggleHabit(String id) {
    final habit = _habits.firstWhere((h) => h.id == id);
    final today = DateTime.now();
    final alreadyCompleted = habit.completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);

    if (alreadyCompleted) {
      habit.completedDates.removeWhere((d) =>
          d.year == today.year && d.month == today.month && d.day == today.day);
    } else {
      habit.completedDates.add(DateTime.now());
    }
    _saveHabits();
    notifyListeners();
  }

  void addShoppingList(ShoppingList list) {
    _shoppingLists.add(list);
    _saveShoppingLists();
    notifyListeners();
  }

  void addShoppingItem(String listId, ShoppingItem item) {
    final list = _shoppingLists.firstWhere((l) => l.id == listId);
    list.items.add(item);
    _saveShoppingLists();
    notifyListeners();
  }

  void toggleShoppingItem(String listId, String itemId) {
    final list = _shoppingLists.firstWhere((l) => l.id == listId);
    final item = list.items.firstWhere((i) => i.id == itemId);
    item.isPurchased = !item.isPurchased;
    _saveShoppingLists();
    notifyListeners();
  }

  void addNote(LifeNote note) {
    _notes.add(note);
    _saveNotes();
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    _saveNotes();
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    SharedPreferences.getInstance().then((prefs) => prefs.setString('userName', name));
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('isDarkMode', value));
    notifyListeners();
  }

  List<Task> get todayTasks => _tasks
      .where((t) =>
          t.dueDate != null &&
          t.dueDate!.year == DateTime.now().year &&
          t.dueDate!.month == DateTime.now().month &&
          t.dueDate!.day == DateTime.now().day)
      .toList();

  List<Task> get upcomingTasks => _tasks
      .where((t) =>
          t.dueDate != null && t.dueDate!.isAfter(DateTime.now()))
      .toList();

  CalendarEvent? get nextEvent {
    if (_events.isEmpty) return null;
    final futureEvents = _events.where((e) => e.startDate.isAfter(DateTime.now())).toList();
    futureEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
    return futureEvents.isNotEmpty ? futureEvents.first : null;
  }
}
