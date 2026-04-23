import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../settings/domain/app_settings.dart';
import '../../settings/state/settings_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_routeNext);
  }

  Future<void> _routeNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) {
      return;
    }
    final settings = ref.read(settingsControllerProvider).valueOrNull ?? const AppSettings();
    context.go(settings.onboardingCompleted ? '/dashboard' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.tertiary, scheme.secondary],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.spa_rounded, size: 72, color: Colors.white),
              SizedBox(height: 14),
              Text(
                'BloomList',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 8),
              Text('Make your day bloom', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
