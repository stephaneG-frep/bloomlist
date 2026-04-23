import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../tasks/domain/task_item.dart';
import '../../tasks/state/tasks_controller.dart';

class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(allTasksProvider);

    List<TaskItem> filter(TaskStatus status) => tasks.where((task) => task.status == status).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Vue Kanban')),
      body: Row(
        children: [
          _KanbanColumn(
            title: 'À faire',
            tasks: filter(TaskStatus.todo),
            color: Colors.blueGrey.shade100,
            targetStatus: TaskStatus.todo,
          ),
          _KanbanColumn(
            title: 'En cours',
            tasks: filter(TaskStatus.inProgress),
            color: Colors.orange.shade100,
            targetStatus: TaskStatus.inProgress,
          ),
          _KanbanColumn(
            title: 'Terminé',
            tasks: filter(TaskStatus.done),
            color: Colors.green.shade100,
            targetStatus: TaskStatus.done,
          ),
        ],
      ),
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  const _KanbanColumn({
    required this.title,
    required this.tasks,
    required this.color,
    required this.targetStatus,
  });

  final String title;
  final List<TaskItem> tasks;
  final Color color;
  final TaskStatus targetStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTasks = ref.watch(allTasksProvider);
    return Expanded(
      child: DragTarget<String>(
        onAcceptWithDetails: (details) async {
          final candidates = allTasks.where((task) => task.id == details.data);
          if (candidates.isEmpty) {
            return;
          }
          final task = candidates.first;
          await ref.read(tasksControllerProvider.notifier).setStatus(task, targetStatus);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: (isHovering ? color.withValues(alpha: 0.55) : color.withValues(alpha: 0.35)),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return LongPressDraggable<String>(
                        data: task.id,
                        feedback: Material(
                          color: Colors.transparent,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.35,
                          child: _TaskKanbanCard(task: task),
                        ),
                        child: _TaskKanbanCard(task: task),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TaskKanbanCard extends StatelessWidget {
  const _TaskKanbanCard({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push('/task/${task.id}'),
        dense: true,
        title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('P: ${task.priority.name}'),
      ),
    );
  }
}
