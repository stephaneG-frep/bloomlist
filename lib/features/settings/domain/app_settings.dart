class AppSettings {
  const AppSettings({
    this.onboardingCompleted = false,
    this.useDarkMode = false,
    this.seedIndex = 0,
    this.notificationsEnabled = true,
    this.pomodoroFocusMinutes = 25,
    this.pomodoroShortBreakMinutes = 5,
    this.pomodoroLongBreakMinutes = 15,
  });

  final bool onboardingCompleted;
  final bool useDarkMode;
  final int seedIndex;
  final bool notificationsEnabled;
  final int pomodoroFocusMinutes;
  final int pomodoroShortBreakMinutes;
  final int pomodoroLongBreakMinutes;

  AppSettings copyWith({
    bool? onboardingCompleted,
    bool? useDarkMode,
    int? seedIndex,
    bool? notificationsEnabled,
    int? pomodoroFocusMinutes,
    int? pomodoroShortBreakMinutes,
    int? pomodoroLongBreakMinutes,
  }) {
    return AppSettings(
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      useDarkMode: useDarkMode ?? this.useDarkMode,
      seedIndex: seedIndex ?? this.seedIndex,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      pomodoroFocusMinutes: pomodoroFocusMinutes ?? this.pomodoroFocusMinutes,
      pomodoroShortBreakMinutes: pomodoroShortBreakMinutes ?? this.pomodoroShortBreakMinutes,
      pomodoroLongBreakMinutes: pomodoroLongBreakMinutes ?? this.pomodoroLongBreakMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'onboardingCompleted': onboardingCompleted,
      'useDarkMode': useDarkMode,
      'seedIndex': seedIndex,
      'notificationsEnabled': notificationsEnabled,
      'pomodoroFocusMinutes': pomodoroFocusMinutes,
      'pomodoroShortBreakMinutes': pomodoroShortBreakMinutes,
      'pomodoroLongBreakMinutes': pomodoroLongBreakMinutes,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      onboardingCompleted: (map['onboardingCompleted'] as bool?) ?? false,
      useDarkMode: (map['useDarkMode'] as bool?) ?? false,
      seedIndex: (map['seedIndex'] as int?) ?? 0,
      notificationsEnabled: (map['notificationsEnabled'] as bool?) ?? true,
      pomodoroFocusMinutes: (map['pomodoroFocusMinutes'] as int?) ?? 25,
      pomodoroShortBreakMinutes: (map['pomodoroShortBreakMinutes'] as int?) ?? 5,
      pomodoroLongBreakMinutes: (map['pomodoroLongBreakMinutes'] as int?) ?? 15,
    );
  }
}
