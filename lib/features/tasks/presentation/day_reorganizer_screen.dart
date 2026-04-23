import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/bloom_card.dart';
import '../../../core/widgets/bloom_shell_background.dart';
import '../state/tasks_controller.dart';

class DayReorganizerScreen extends ConsumerWidget {
  const DayReorganizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(dayPlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réorganisation de journée')),
      body: BloomShellBackground(
        child: slots.isEmpty
            ? const Center(child: Text('Aucune suggestion disponible pour le moment.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  BloomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Plan conseillé', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        const Text('Ordre optimisé selon énergie, priorité et échéances proches.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...slots.map(
                    (slot) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(slot.task.title),
                        subtitle: Text('${slot.task.priority.name} · ${slot.task.energy.name}'),
                        trailing: Text(
                          '${DateFormat('HH:mm').format(slot.start)}-${DateFormat('HH:mm').format(slot.end)}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(tasksControllerProvider.notifier)
                          .applyDayPlan(slots.map((slot) => slot.task.id).toList(), startAt: DateTime.now());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Journée réorganisée et échéances mises à jour.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_fix_high_rounded),
                    label: const Text('Appliquer ce plan'),
                  ),
                ],
              ),
      ),
    );
  }
}
