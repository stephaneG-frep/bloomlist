import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/logging/error_logger_provider.dart';
import '../../../core/notifications/notification_providers.dart';
import '../domain/app_settings.dart';
import '../state/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<bool?> _exactAlarmFuture;

  @override
  void initState() {
    super.initState();
    _exactAlarmFuture = ref.read(localNotificationsServiceProvider).canScheduleExactAlarms();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
    final controller = ref.read(settingsControllerProvider.notifier);
    final latestErrors = ref.read(appErrorLoggerProvider).latest(limit: 5);

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: FutureBuilder<bool?>(
                future: _exactAlarmFuture,
                builder: (context, snapshot) {
                  final canExact = snapshot.data;
                  final isUnknown = canExact == null;
                  final isGranted = canExact == true;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Alarmes exactes Android', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        isUnknown
                            ? 'Statut non disponible sur cet appareil.'
                            : isGranted
                                ? 'Autorisé: les rappels précis sont actifs.'
                                : 'Non autorisé: BloomList utilise un mode de rappel approximatif.',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              final granted = await ref
                                  .read(localNotificationsServiceProvider)
                                  .requestExactAlarmPermission();
                              setState(() {
                                _exactAlarmFuture = ref
                                    .read(localNotificationsServiceProvider)
                                    .canScheduleExactAlarms();
                              });
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    granted
                                        ? 'Alarme exacte autorisée.'
                                        : 'Permission non accordée, fallback activé.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.alarm_on_rounded),
                            label: const Text('Activer alarmes exactes'),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _exactAlarmFuture = ref
                                  .read(localNotificationsServiceProvider)
                                  .canScheduleExactAlarms();
                            }),
                            child: const Text('Actualiser'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (latestErrors.isNotEmpty)
            Card(
              child: ExpansionTile(
                title: const Text('Journal de fiabilité'),
                subtitle: const Text('Dernières erreurs capturées localement'),
                children: latestErrors
                    .map(
                      (entry) => ListTile(
                        dense: true,
                        title: Text(
                          entry.split('\n').first,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
              ),
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
