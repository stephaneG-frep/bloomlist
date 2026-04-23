import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bloom_card.dart';
import '../domain/task_item.dart';
import '../state/tasks_controller.dart';

class TaskDetailScreen extends ConsumerWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidates = ref.watch(allTasksProvider).where((item) => item.id == taskId);
    final task = candidates.isEmpty ? null : candidates.first;

    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tâche introuvable')),
        body: const Center(child: Text('Cette tâche n\'existe plus.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la tâche'),
        actions: [
          IconButton(onPressed: () => context.push('/task/${task.id}/edit'), icon: const Icon(Icons.edit_rounded)),
          IconButton(
            onPressed: () async {
              await ref.read(tasksControllerProvider.notifier).deleteTask(task.id);
              if (context.mounted) {
                context.pop();
              }
            },
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          BloomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (task.description.isNotEmpty) Text(task.description),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text('Priorité: ${task.priority.name}')),
                    Chip(label: Text('Énergie: ${task.energy.name}')),
                    Chip(label: Text('Statut: ${task.status.name}')),
                    Chip(label: Text('Estimation: ${task.estimatedMinutes} min')),
                    if (task.category != null) Chip(label: Text('Catégorie: ${task.category}')),
                    if (task.isRecurring && task.recurrenceRule != null)
                      Chip(label: Text('Récurrence: ${task.recurrenceRule}')),
                  ],
                ),
                if (task.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task.tags.map((tag) => Chip(label: Text('#$tag'))).toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Text('Échéance: ${task.dueDate == null ? 'Aucune' : DateFormat('EEEE d MMMM, HH:mm', 'fr').format(task.dueDate!)}'),
                Text('Rappel: ${task.reminderAt == null ? 'Aucun' : DateFormat('EEEE d MMMM, HH:mm', 'fr').format(task.reminderAt!)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BloomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sous-tâches', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (task.subTasks.isEmpty)
                  const Text('Aucune sous-tâche pour le moment.')
                else
                  ...task.subTasks.map(
                    (subTask) => CheckboxListTile(
                      value: subTask.isDone,
                      title: Text(subTask.title),
                      onChanged: (_) {
                        ref.read(tasksControllerProvider.notifier).toggleSubTask(task, subTask);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final nextStatus = task.status == TaskStatus.done ? TaskStatus.todo : TaskStatus.done;
              await ref.read(tasksControllerProvider.notifier).setStatus(task, nextStatus);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      nextStatus == TaskStatus.done
                          ? 'Super, tâche complétée !'
                          : 'Tâche réactivée.',
                    ),
                  ),
                );
              }
            },
            icon: Icon(task.isDone ? Icons.replay_rounded : Icons.check_circle_rounded),
            label: Text(task.isDone ? 'Marquer en cours' : 'Marquer comme terminée'),
          ),
        ],
      ),
    );
  }
}
