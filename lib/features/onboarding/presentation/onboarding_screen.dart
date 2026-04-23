import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/state/settings_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _steps = <({String title, String subtitle, IconData icon})>[
    (
      title: 'Pilote ton énergie',
      subtitle: 'Planifie selon ton niveau d’énergie: faible, moyen, élevé.',
      icon: Icons.bolt_rounded,
    ),
    (
      title: 'Vue riche et immersive',
      subtitle: 'Dashboard, vue semaine, calendrier et kanban dans une seule expérience.',
      icon: Icons.dashboard_customize_rounded,
    ),
    (
      title: 'Reste dans le flow',
      subtitle: 'Pomodoro, mode focus et progression visuelle motivante chaque jour.',
      icon: Icons.timelapse_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: (value) => setState(() => _index = value),
              itemBuilder: (context, index) {
                final step = _steps[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.primary.withValues(alpha: 0.16),
                        scheme.tertiary.withValues(alpha: 0.09),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(step.icon, size: 104, color: scheme.primary),
                      const SizedBox(height: 28),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(step.subtitle, textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _steps.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: i == _index ? 28 : 8,
                      decoration: BoxDecoration(
                        color: i == _index ? scheme.primary : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (_index < _steps.length - 1) {
                        await _pageController.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                        return;
                      }
                      await ref.read(settingsControllerProvider.notifier).setOnboardingCompleted();
                      if (!context.mounted) {
                        return;
                      }
                      context.go('/dashboard');
                    },
                    child: Text(_index == _steps.length - 1 ? 'Commencer BloomList' : 'Continuer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
