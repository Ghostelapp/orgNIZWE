import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/habit.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nawyki')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.habits.length,
        itemBuilder: (context, index) {
          final habit = provider.habits[index];
          return _HabitCard(habit: habit);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowy nawyk'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Nazwa nawyku'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Anuluj'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                context.read<AppProvider>().addHabit(Habit(
                      title: titleController.text,
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
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  const _HabitCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isDone = habit.completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);
    final progress = habit.weeklyProgress.clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(isDone ? Icons.check_circle : Icons.circle_outlined),
                  color: isDone ? Colors.green : null,
                  onPressed: () => context.read<AppProvider>().toggleHabit(habit.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Seria: ${habit.currentStreak} dni',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
