import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/focus/presentation/focus_mode_screen.dart';
import '../../features/kanban/presentation/kanban_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/projects/presentation/projects_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/tasks/presentation/day_reorganizer_screen.dart';
import '../../features/tasks/presentation/quick_tasks_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/tasks/presentation/task_editor_screen.dart';
import '../../features/tasks/presentation/tasks_list_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      GoRoute(path: '/tasks', builder: (context, state) => const TasksListScreen()),
      GoRoute(path: '/projects', builder: (context, state) => const ProjectsScreen()),
      GoRoute(path: '/calendar', builder: (context, state) => const CalendarScreen()),
      GoRoute(path: '/kanban', builder: (context, state) => const KanbanScreen()),
      GoRoute(path: '/focus', builder: (context, state) => const FocusModeScreen()),
      GoRoute(path: '/stats', builder: (context, state) => const StatsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/tasks/quick', builder: (context, state) => const QuickTasksScreen()),
      GoRoute(path: '/tasks/reorganize', builder: (context, state) => const DayReorganizerScreen()),
      GoRoute(path: '/task/new', builder: (context, state) => const TaskEditorScreen()),
      GoRoute(
        path: '/task/:id',
        builder: (_, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/task/:id/edit',
        builder: (_, state) => TaskEditorScreen(taskId: state.pathParameters['id']),
      ),
    ],
  );
}
