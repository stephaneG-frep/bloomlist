import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/bloom_card.dart';
import '../../../core/widgets/bloom_shell_background.dart';
import '../../tasks/domain/task_item.dart';
import '../../tasks/state/tasks_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(dashboardProgressProvider);
    final openTasks = ref.watch(openTasksCountProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final weekTasks = ref.watch(weekTasksProvider);
    final smartSuggestions = ref.watch(smartSuggestionsProvider);
    final suggestedEnergy = ref.watch(suggestedEnergyProvider);

    String energyLabel(EnergyLevel level) {
      switch (level) {
        case EnergyLevel.low:
          return 'faible';
        case EnergyLevel.medium:
          return 'moyen';
        case EnergyLevel.high:
          return 'élevé';
      }
    }

    return Scaffold(
      body: BloomShellBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('BloomList'),
              floating: true,
              actions: [
                IconButton(onPressed: () => context.push('/settings'), icon: const Icon(Icons.tune_rounded)),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  BloomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Progression du jour', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(value: progress, minHeight: 12),
                        ),
                        const SizedBox(height: 8),
                        Text('${(progress * 100).round()}% complété · $openTasks tâches ouvertes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniActionCard(
                          icon: Icons.today_rounded,
                          label: 'Aujourd’hui',
                          value: '${todayTasks.length}',
                          onTap: () => context.push('/tasks'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniActionCard(
                          icon: Icons.view_week_rounded,
                          label: 'Semaine',
                          value: '${weekTasks.length}',
                          onTap: () => context.push('/calendar'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => context.push('/task/new'),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Nouvelle tâche'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/kanban'),
                        icon: const Icon(Icons.view_kanban_rounded),
                        label: const Text('Vue Kanban'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/focus'),
                        icon: const Icon(Icons.center_focus_strong_rounded),
                        label: const Text('Mode focus'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/tasks/quick'),
                        icon: const Icon(Icons.bolt_rounded),
                        label: const Text('Rapides'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/tasks/reorganize'),
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: const Text('Réorganiser'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/stats'),
                        icon: const Icon(Icons.auto_graph_rounded),
                        label: const Text('Statistiques'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  BloomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recommandation intelligente', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('Énergie suggérée maintenant: ${energyLabel(suggestedEnergy)}'),
                        const SizedBox(height: 8),
                        if (smartSuggestions.isEmpty)
                          const Text('Crée une tâche pour recevoir des suggestions intelligentes.')
                        else
                          ...smartSuggestions.take(3).map(
                                (task) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: Text(task.title),
                                  subtitle: Text('${task.priority.name} · ${task.estimatedMinutes} min'),
                                  trailing: const Icon(Icons.chevron_right_rounded),
                                  onTap: () => context.push('/task/${task.id}'),
                                ),
                              ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => context.push('/tasks/quick'),
                          icon: const Icon(Icons.flash_on_rounded),
                          label: const Text('Vue petites tâches rapides'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  BloomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Navigation', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.list_alt_rounded),
                          title: const Text('Tâches'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/tasks'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.folder_special_rounded),
                          title: const Text('Projets'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/projects'),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_month_rounded),
                          title: const Text('Calendrier'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => context.push('/calendar'),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BloomCard(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
