import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zadania'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Dzisiaj'),
              Tab(text: 'Jutro'),
              Tab(text: 'Nadchodzące'),
              Tab(text: 'Bez terminu'),
              Tab(text: 'Ukończone'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _TaskList(tasks: _filterToday(provider.tasks)),
            _TaskList(tasks: _filterTomorrow(provider.tasks)),
            _TaskList(tasks: _filterUpcoming(provider.tasks)),
            _TaskList(tasks: provider.tasks.where((t) => t.dueDate == null).toList()),
            _TaskList(tasks: provider.tasks.where((t) => t.isCompleted).toList()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Task> _filterToday(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).toList();
  }

  List<Task> _filterTomorrow(List<Task> tasks) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == tomorrow.year &&
          t.dueDate!.month == tomorrow.month &&
          t.dueDate!.day == tomorrow.day;
    }).toList();
  }

  List<Task> _filterUpcoming(List<Task> tasks) {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.isAfter(now.add(const Duration(days: 1)));
    }).toList();
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? dueDate;
    TaskPriority priority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowe zadanie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Tytuł zadania'),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  ListTile(
                    title: const Text('Termin'),
                    subtitle: Text(dueDate == null
                        ? 'Brak'
                        : DateFormat('d MMMM', 'pl_PL').format(dueDate!)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => dueDate = picked);
                    },
                  ),
                  DropdownButtonFormField<TaskPriority>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Priorytet'),
                    items: TaskPriority.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(_priorityLabel(p)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => priority = value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<AppProvider>().addTask(Task(
                      title: titleController.text,
                      dueDate: dueDate,
                      priority: priority,
                    ));
                Navigator.pop(context);
              }
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  String _priorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Wysoki';
      case TaskPriority.medium:
        return 'Średni';
      case TaskPriority.low:
        return 'Niski';
    }
  }
}

class _TaskList extends StatelessWidget {
  final List<Task> tasks;
  const _TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Brak zadań'));
    }
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) {},
      children: tasks
          .map((task) => _TaskTile(key: ValueKey(task.id), task: task))
          .toList(),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (_) => context.read<AppProvider>().toggleTask(task.id),
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: task.dueDate != null
          ? Text(DateFormat('d MMMM', 'pl_PL').format(task.dueDate!))
          : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<AppProvider>().deleteTask(task.id),
      ),
    );
  }
}
