import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bloom_shell_background.dart';
import '../../tasks/state/tasks_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(allTasksProvider).where((t) {
      final due = t.dueDate;
      if (due == null) {
        return false;
      }
      return due.year == _selected.year && due.month == _selected.month && due.day == _selected.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: BloomShellBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                title: Text(DateFormat('EEEE d MMMM yyyy', 'fr').format(_selected)),
                subtitle: const Text('Sélectionne un jour'),
                trailing: const Icon(Icons.edit_calendar_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                    initialDate: _selected,
                  );
                  if (picked != null) {
                    setState(() => _selected = picked);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Text('Tâches du jour', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (tasks.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Aucune échéance ce jour-là.')))
            else
              ...tasks.map(
                (task) => Card(
                  child: ListTile(
                    onTap: () => context.push('/task/${task.id}'),
                    title: Text(task.title),
                    subtitle: Text('${task.priority.name} · ${task.energy.name}'),
                    trailing: Text(DateFormat('HH:mm').format(task.dueDate!)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
