import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import 'tasks_screen.dart';
import 'calendar_screen.dart';
import 'habits_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Dzień dobry';
    if (hour < 18) return 'Dzień dobry';
    return 'Dobry wieczór';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final todayTasks = provider.todayTasks;
    final nextEvent = provider.nextEvent;
    final todayHabits = provider.habits;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM', 'pl_PL').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_greeting()}${provider.userName.isNotEmpty ? ', ${provider.userName}' : ''}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todayTasks.isEmpty
                          ? 'Masz dziś spokojny dzień.'
                          : 'Masz dziś ${todayTasks.length} ${todayTasks.length == 1 ? 'rzecz' : todayTasks.length < 5 ? 'rzeczy' : 'rzeczy'} do zrobienia.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'Najważniejsze zadania',
                child: todayTasks.isEmpty
                    ? _buildEmptyState('Brak zadań na dziś')
                    : Column(
                        children: todayTasks
                            .take(3)
                            .map((task) => _TaskCard(task: task))
                            .toList(),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'Najbliższe wydarzenie',
                child: nextEvent == null
                    ? _buildEmptyState('Brak nadchodzących wydarzeń')
                    : ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(Icons.event,
                              color: Theme.of(context).colorScheme.onPrimaryContainer),
                        ),
                        title: Text(nextEvent.title),
                        subtitle: Text(
                          DateFormat('HH:mm', 'pl_PL').format(nextEvent.startDate),
                        ),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'Nawyki na dziś',
                child: todayHabits.isEmpty
                    ? _buildEmptyState('Brak nawyków do śledzenia')
                    : SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todayHabits.length,
                          itemBuilder: (context, index) {
                            final habit = todayHabits[index];
                            return _HabitChip(habit: habit);
                          },
                        ),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showQuickAdd(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Szybka akcja'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Dodaj zadanie'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TasksScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Dodaj wydarzenie'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CalendarScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_fire_department),
              title: const Text('Dodaj nawyk'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HabitsScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
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
        trailing: _PriorityBadge(priority: task.priority),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        label = 'Wysoki';
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        label = 'Średni';
        break;
      case TaskPriority.low:
        color = Colors.green;
        label = 'Niski';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final Habit habit;
  const _HabitChip({required this.habit});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isDone = habit.completedDates.any((d) =>
        d.year == today.year && d.month == today.month && d.day == today.day);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => context.read<AppProvider>().toggleHabit(habit.id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDone
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDone ? Icons.check_circle : Icons.circle_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                habit.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
