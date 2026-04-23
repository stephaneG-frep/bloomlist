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

  Future<void> _showCompletionPulse() async {
    Future<void>.delayed(const Duration(milliseconds: 750), () {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'done',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.black.withValues(alpha: 0.15)),
            ),
            Center(
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                      SizedBox(width: 10),
                      Text('Tâche terminée'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Toutes')),
                    ButtonSegment(value: 1, label: Text('Aujourd\'hui')),
                    ButtonSegment(value: 2, label: Text('Semaine')),
                    ButtonSegment(value: 3, label: Text('Rapides')),
                  ],
                  selected: {_segment},
                  onSelectionChanged: (set) => setState(() => _segment = set.first),
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
                        await _showCompletionPulse();
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
