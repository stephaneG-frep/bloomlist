import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/app_settings.dart';

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    return ref.read(localDataSourceProvider).loadSettings();
  }

  Future<void> saveSettings(AppSettings next) async {
    await ref.read(localDataSourceProvider).saveSettings(next);
    state = AsyncData(next);
  }

  Future<void> setOnboardingCompleted() async {
    final current = state.value ?? const AppSettings();
    await saveSettings(current.copyWith(onboardingCompleted: true));
  }

  Future<void> setDarkMode(bool enabled) async {
    final current = state.value ?? const AppSettings();
    await saveSettings(current.copyWith(useDarkMode: enabled));
  }

  Future<void> setSeedIndex(int seed) async {
    final current = state.value ?? const AppSettings();
    await saveSettings(current.copyWith(seedIndex: seed));
  }

  Future<void> setNotifications(bool enabled) async {
    final current = state.value ?? const AppSettings();
    await saveSettings(current.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setPomodoro({required int focus, required int shortBreak, required int longBreak}) async {
    final current = state.value ?? const AppSettings();
    await saveSettings(
      current.copyWith(
        pomodoroFocusMinutes: focus,
        pomodoroShortBreakMinutes: shortBreak,
        pomodoroLongBreakMinutes: longBreak,
      ),
    );
  }
}

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsControllerProvider).valueOrNull ?? const AppSettings();
  return settings.useDarkMode ? ThemeMode.dark : ThemeMode.light;
});
