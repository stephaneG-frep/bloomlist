import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/bloom_shell_background.dart';
import '../domain/task_item.dart';
import '../state/tasks_controller.dart';
import 'task_tile.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(allTasksProvider);
    final today = ref.watch(todayTasksProvider);
    final week = ref.watch(weekTasksProvider);
    final quick = ref.watch(quickTasksProvider);

    final List<TaskItem> selected;
    switch (_segment) {
      case 1:
        selected = today;
      case 2:
        selected = week;
      case 3:
        selected = quick;
      default:
        selected = allTasks;
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/task/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle tâche'),
      ),
      body: BloomShellBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('Tâches BloomList'),
              floating: true,
              actions: [
                IconButton(onPressed: () => context.push('/kanban'), icon: const Icon(Icons.view_kanban_rounded)),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Toutes',
                        selected: _segment == 0,
                        onTap: () => setState(() => _segment = 0),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Aujourd\'hui',
                        selected: _segment == 1,
                        onTap: () => setState(() => _segment = 1),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Semaine',
                        selected: _segment == 2,
                        onTap: () => setState(() => _segment = 2),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Rapides',
                        selected: _segment == 3,
                        onTap: () => setState(() => _segment = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (selected.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('Aucune tâche ici pour l’instant.'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList.builder(
                  itemCount: selected.length,
                  itemBuilder: (context, index) {
                    final task = selected[index];
                    return TaskTile(
                      task: task,
                      onTap: () => context.push('/task/${task.id}'),
                      onStatusChanged: (status) async {
                        await ref.read(tasksControllerProvider.notifier).setStatus(task, status);
                        if (!context.mounted || status != TaskStatus.done) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tâche terminée')),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? scheme.primaryContainer : scheme.surface,
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
