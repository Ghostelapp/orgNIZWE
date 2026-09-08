import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/app_provider.dart';
import '../models/event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay, provider.events);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalendarz')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(day, provider.events),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            locale: 'pl_PL',
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(event.title),
                  subtitle: Text(
                    '${DateFormat('HH:mm', 'pl_PL').format(event.startDate)} - ${DateFormat('HH:mm', 'pl_PL').format(event.endDate)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => provider.deleteEvent(event.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<CalendarEvent> _getEventsForDay(DateTime day, List<CalendarEvent> events) {
    return events.where((e) {
      return e.startDate.year == day.year &&
          e.startDate.month == day.month &&
          e.startDate.day == day.day;
    }).toList();
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime date = _selectedDay ?? DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 12, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nowe wydarzenie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  ListTile(
                    title: const Text('Data'),
                    subtitle: Text(DateFormat('d MMMM', 'pl_PL').format(date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => date = picked);
                    },
                  ),
                  ListTile(
                    title: const Text('Godzina rozpoczęcia'),
                    subtitle: Text(startTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                  ListTile(
                    title: const Text('Godzina zakończenia'),
                    subtitle: Text(endTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) setState(() => endTime = picked);
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
                final startDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  startTime.hour,
                  startTime.minute,
                );
                final endDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  endTime.hour,
                  endTime.minute,
                );
                context.read<AppProvider>().addEvent(CalendarEvent(
                      title: titleController.text,
                      startDate: startDate,
                      endDate: endDate,
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
