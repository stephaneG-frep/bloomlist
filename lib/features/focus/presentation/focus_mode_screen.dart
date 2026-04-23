import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/bloom_card.dart';
import '../../../core/widgets/bloom_shell_background.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/state/settings_controller.dart';
import '../../tasks/domain/task_item.dart';
import '../../tasks/state/tasks_controller.dart';
import '../state/focus_timer_controller.dart';

class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen> {
  EnergyLevel _selectedEnergy = EnergyLevel.medium;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(focusTimerControllerProvider);
    final timerController = ref.read(focusTimerControllerProvider.notifier);
    final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
    final suggestions = ref.watch(tasksByEnergyProvider(_selectedEnergy));

    String format(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final secs = (seconds % 60).toString().padLeft(2, '0');
      return '$minutes:$secs';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mode Focus & Pomodoro')),
      body: BloomShellBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            BloomCard(
              child: Column(
                children: [
                  const Text('Pomodoro'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(value: timer.progress, strokeWidth: 11),
                        Text(format(timer.remainingSeconds), style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: timer.isRunning ? timerController.pause : timerController.start,
                        icon: Icon(timer.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                        label: Text(timer.isRunning ? 'Pause' : 'Démarrer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: timerController.reset,
                        icon: const Icon(Icons.replay_rounded),
                        label: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: Text('Focus ${settings.pomodoroFocusMinutes}m'),
                        onPressed: () => timerController.setDurationMinutes(settings.pomodoroFocusMinutes),
                      ),
                      ActionChip(
                        label: Text('Pause ${settings.pomodoroShortBreakMinutes}m'),
                        onPressed: () => timerController.setDurationMinutes(settings.pomodoroShortBreakMinutes),
                      ),
                      ActionChip(
                        label: Text('Longue ${settings.pomodoroLongBreakMinutes}m'),
                        onPressed: () => timerController.setDurationMinutes(settings.pomodoroLongBreakMinutes),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            BloomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Suggestions selon ton énergie', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<EnergyLevel>(
                    segments: const [
                      ButtonSegment(value: EnergyLevel.low, label: Text('Faible')),
                      ButtonSegment(value: EnergyLevel.medium, label: Text('Moyen')),
                      ButtonSegment(value: EnergyLevel.high, label: Text('Élevé')),
                    ],
                    selected: {_selectedEnergy},
                    onSelectionChanged: (value) => setState(() => _selectedEnergy = value.first),
                  ),
                  const SizedBox(height: 10),
                  if (suggestions.isEmpty)
                    const Text('Aucune tâche disponible pour ce niveau.')
                  else
                    ...suggestions.take(4).map(
                      (task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.task_alt_rounded),
                        title: Text(task.title),
                        subtitle: Text('${task.priority.name} · ${task.estimatedMinutes} min'),
                        onTap: () => context.push('/task/${task.id}'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/tasks/reorganize'),
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Réorganiser ma journée'),
            ),
          ],
        ),
      ),
    );
  }
}
