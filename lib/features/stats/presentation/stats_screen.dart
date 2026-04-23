import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/bloom_card.dart';
import '../../../core/widgets/bloom_shell_background.dart';
import '../../tasks/state/tasks_controller.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(allTasksProvider);
    final completed = tasks.where((task) => task.isDone).length;
    final open = tasks.length - completed;
    final averageEstimate = tasks.isEmpty
        ? 0
        : (tasks.map((task) => task.estimatedMinutes).reduce((a, b) => a + b) / tasks.length).round();

    final energyGroups = {
      'Faible': tasks.where((task) => task.energy.name == 'low').length,
      'Moyen': tasks.where((task) => task.energy.name == 'medium').length,
      'Élevé': tasks.where((task) => task.energy.name == 'high').length,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: BloomShellBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BloomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Performance générale', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Total tâches: ${tasks.length}'),
                  Text('Terminées: $completed'),
                  Text('Ouvertes: $open'),
                  Text('Estimation moyenne: $averageEstimate min'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BloomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Répartition énergie', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...energyGroups.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(entry.key), Text('${entry.value}')],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
