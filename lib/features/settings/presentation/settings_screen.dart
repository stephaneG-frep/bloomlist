import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/app_settings.dart';
import '../state/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres & Personnalisation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            value: settings.useDarkMode,
            title: const Text('Mode sombre'),
            onChanged: controller.setDarkMode,
          ),
          const SizedBox(height: 8),
          Text('Palette visuelle', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(
              BloomPalette.seeds.length,
              (index) {
                final color = BloomPalette.seeds[index];
                final selected = index == settings.seedIndex;
                return GestureDetector(
                  onTap: () => controller.setSeedIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: settings.notificationsEnabled,
            title: const Text('Rappels activés'),
            onChanged: controller.setNotifications,
          ),
          const Divider(height: 24),
          Text('Durées Pomodoro', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _StepperRow(
            label: 'Focus',
            value: settings.pomodoroFocusMinutes,
            onChanged: (value) => controller.setPomodoro(
              focus: value,
              shortBreak: settings.pomodoroShortBreakMinutes,
              longBreak: settings.pomodoroLongBreakMinutes,
            ),
          ),
          _StepperRow(
            label: 'Pause courte',
            value: settings.pomodoroShortBreakMinutes,
            onChanged: (value) => controller.setPomodoro(
              focus: settings.pomodoroFocusMinutes,
              shortBreak: value,
              longBreak: settings.pomodoroLongBreakMinutes,
            ),
          ),
          _StepperRow(
            label: 'Pause longue',
            value: settings.pomodoroLongBreakMinutes,
            onChanged: (value) => controller.setPomodoro(
              focus: settings.pomodoroFocusMinutes,
              shortBreak: settings.pomodoroShortBreakMinutes,
              longBreak: value,
            ),
          ),
          const Divider(height: 28),
          FilledButton.icon(
            onPressed: () => context.push('/projects'),
            icon: const Icon(Icons.folder_special_rounded),
            label: const Text('Gérer les projets'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push('/stats'),
            icon: const Icon(Icons.insights_rounded),
            label: const Text('Voir les statistiques'),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline_rounded),
        ),
        Text('$value min'),
        IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline_rounded)),
      ],
    );
  }
}
