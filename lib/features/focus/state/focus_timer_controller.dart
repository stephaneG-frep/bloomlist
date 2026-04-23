import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/notifications/notification_providers.dart';

class FocusTimerState {
  const FocusTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
  });

  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;

  double get progress {
    if (totalSeconds == 0) {
      return 0;
    }
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class FocusTimerController extends Notifier<FocusTimerState> {
  Timer? _timer;

  @override
  FocusTimerState build() {
    ref.onDispose(() => _timer?.cancel());
    return const FocusTimerState(totalSeconds: 25 * 60, remainingSeconds: 25 * 60, isRunning: false);
  }

  void setDurationMinutes(int minutes) {
    _timer?.cancel();
    final seconds = minutes * 60;
    state = FocusTimerState(totalSeconds: seconds, remainingSeconds: seconds, isRunning: false);
  }

  void start() {
    if (state.isRunning || state.remainingSeconds == 0) {
      return;
    }
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        state = state.copyWith(remainingSeconds: 0, isRunning: false);
        ref.read(localNotificationsServiceProvider).showPomodoroCompleted();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(remainingSeconds: state.totalSeconds, isRunning: false);
  }
}

final focusTimerControllerProvider =
    NotifierProvider<FocusTimerController, FocusTimerState>(FocusTimerController.new);
