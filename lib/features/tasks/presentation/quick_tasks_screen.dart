import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/task_item.dart';
import '../state/tasks_controller.dart';
import 'task_tile.dart';

class QuickTasksScreen extends ConsumerWidget {
  const QuickTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(quickTasksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Petites tâches rapides')),
      body: tasks.isEmpty
          ? const Center(child: Text('Aucune tâche rapide disponible.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskTile(
                  task: task,
                  onTap: () => context.push('/task/${task.id}'),
                  onStatusChanged: (status) async {
                    await ref.read(tasksControllerProvider.notifier).setStatus(task, status);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final todo = tasks.where((task) => task.status != TaskStatus.done).toList();
          for (final task in todo) {
            await ref.read(tasksControllerProvider.notifier).setStatus(task, TaskStatus.done);
          }
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Session rapide terminée. Excellent rythme.')),
            );
          }
        },
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('Terminer les rapides'),
      ),
    );
  }
}
