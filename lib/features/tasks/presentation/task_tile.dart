import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/task_item.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onStatusChanged,
  });

  final TaskItem task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final dueLabel = task.dueDate == null ? null : DateFormat('EEE d MMM · HH:mm').format(task.dueDate!);
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: DropdownButtonHideUnderline(
          child: DropdownButton<TaskStatus>(
            value: task.status,
            items: TaskStatus.values
                .map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Icon(
                      status == TaskStatus.done
                          ? Icons.check_circle_rounded
                          : status == TaskStatus.inProgress
                              ? Icons.timelapse_rounded
                              : Icons.radio_button_unchecked_rounded,
                      color: status == TaskStatus.done
                          ? Colors.green
                          : status == TaskStatus.inProgress
                              ? scheme.primary
                              : scheme.outline,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onStatusChanged(value);
              }
            },
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration: task.isDone ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(task.priority.name),
                  avatar: CircleAvatar(backgroundColor: task.priorityColor, radius: 5),
                ),
                Chip(label: Text('${task.estimatedMinutes} min')),
                Chip(label: Text('Énergie ${task.energy.name}')),
                if (dueLabel != null) Chip(label: Text(dueLabel)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
