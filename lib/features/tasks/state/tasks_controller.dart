import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/task_item.dart';

class TasksController extends AsyncNotifier<List<TaskItem>> {
  final _uuid = const Uuid();

  @override
  Future<List<TaskItem>> build() async {
    return ref.read(localDataSourceProvider).loadTasks();
  }

  Future<void> upsertTask(TaskItem task) async {
    await ref.read(localDataSourceProvider).saveTask(task);
    final current = [...(state.value ?? <TaskItem>[])];
    final index = current.indexWhere((item) => item.id == task.id);
    if (index == -1) {
      current.add(task);
    } else {
      current[index] = task;
    }
    state = AsyncData(current);
  }

  Future<void> createTask({
    required String title,
    required String description,
    required String? projectId,
    required String? category,
    required List<String> tags,
    required TaskPriority priority,
    required EnergyLevel energy,
    required DateTime? dueDate,
    required DateTime? reminderAt,
    required bool isRecurring,
    required String? recurrenceRule,
    required int estimatedMinutes,
    required List<SubTask> subTasks,
  }) async {
    final task = TaskItem(
      id: _uuid.v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      projectId: projectId,
      category: category,
      tags: tags,
      priority: priority,
      energy: energy,
      dueDate: dueDate,
      reminderAt: reminderAt,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
      estimatedMinutes: estimatedMinutes,
      subTasks: subTasks,
    );
    await upsertTask(task);
  }

  Future<void> deleteTask(String id) async {
    await ref.read(localDataSourceProvider).removeTask(id);
    state = AsyncData((state.value ?? <TaskItem>[]).where((task) => task.id != id).toList());
  }

  Future<void> setStatus(TaskItem task, TaskStatus status) async {
    final completedAt = status == TaskStatus.done ? DateTime.now() : null;
    await upsertTask(task.copyWith(status: status, completedAt: completedAt, clearCompletedAt: status != TaskStatus.done));
  }

  Future<void> toggleSubTask(TaskItem task, SubTask subTask) async {
    final updated = task.subTasks
        .map((item) => item.id == subTask.id ? item.copyWith(isDone: !item.isDone) : item)
        .toList();
    await upsertTask(task.copyWith(subTasks: updated));
  }

  Future<void> applyDayPlan(List<String> orderedTaskIds, {DateTime? startAt}) async {
    var pointer = startAt ?? DateTime.now();
    final all = [...(state.value ?? <TaskItem>[])];
    for (final taskId in orderedTaskIds) {
      final index = all.indexWhere((task) => task.id == taskId);
      if (index == -1) {
        continue;
      }
      final task = all[index];
      final updated = task.copyWith(dueDate: pointer);
      all[index] = updated;
      await ref.read(localDataSourceProvider).saveTask(updated);
      pointer = pointer.add(Duration(minutes: updated.estimatedMinutes + 10));
    }
    state = AsyncData(all);
  }
}

final tasksControllerProvider = AsyncNotifierProvider<TasksController, List<TaskItem>>(TasksController.new);

final allTasksProvider = Provider<List<TaskItem>>((ref) {
  return ref.watch(tasksControllerProvider).valueOrNull ?? const <TaskItem>[];
});

final todayTasksProvider = Provider<List<TaskItem>>((ref) {
  final now = DateTime.now();
  final tasks = ref.watch(allTasksProvider);
  return tasks.where((task) {
    final due = task.dueDate;
    if (due == null || task.isDone) {
      return false;
    }
    return due.year == now.year && due.month == now.month && due.day == now.day;
  }).toList()
    ..sort((a, b) => (a.dueDate ?? DateTime(2999)).compareTo(b.dueDate ?? DateTime(2999)));
});

final weekTasksProvider = Provider<List<TaskItem>>((ref) {
  final now = DateTime.now();
  final weekEnd = now.add(const Duration(days: 7));
  return ref
      .watch(allTasksProvider)
      .where((task) => task.dueDate != null && !task.isDone)
      .where((task) => task.dueDate!.isAfter(now.subtract(const Duration(days: 1))))
      .where((task) => task.dueDate!.isBefore(weekEnd.add(const Duration(days: 1))))
      .toList()
    ..sort((a, b) => (a.dueDate ?? DateTime(2999)).compareTo(b.dueDate ?? DateTime(2999)));
});

final quickTasksProvider = Provider<List<TaskItem>>((ref) {
  return ref
      .watch(allTasksProvider)
      .where((task) => !task.isDone && task.estimatedMinutes <= 15)
      .toList()
    ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
});

final tasksByEnergyProvider = Provider.family<List<TaskItem>, EnergyLevel>((ref, energy) {
  return ref
      .watch(allTasksProvider)
      .where((task) => !task.isDone && task.energy == energy)
      .toList()
    ..sort((a, b) => b.priority.index.compareTo(a.priority.index));
});

final dashboardProgressProvider = Provider<double>((ref) {
  final all = ref.watch(allTasksProvider);
  if (all.isEmpty) {
    return 0;
  }
  final done = all.where((task) => task.isDone).length;
  return done / all.length;
});

final openTasksCountProvider = Provider<int>((ref) {
  return ref.watch(allTasksProvider).where((task) => !task.isDone).length;
});

final suggestedEnergyProvider = Provider<EnergyLevel>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 11) {
    return EnergyLevel.high;
  }
  if (hour < 16) {
    return EnergyLevel.medium;
  }
  return EnergyLevel.low;
});

final smartSuggestionsProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(allTasksProvider).where((task) => !task.isDone).toList();
  final suggestedEnergy = ref.watch(suggestedEnergyProvider);
  tasks.sort((a, b) {
    final energyA = a.energy == suggestedEnergy ? 0 : 1;
    final energyB = b.energy == suggestedEnergy ? 0 : 1;
    if (energyA != energyB) {
      return energyA.compareTo(energyB);
    }
    final dueA = a.dueDate ?? DateTime(2999);
    final dueB = b.dueDate ?? DateTime(2999);
    final dueCompare = dueA.compareTo(dueB);
    if (dueCompare != 0) {
      return dueCompare;
    }
    return b.priority.index.compareTo(a.priority.index);
  });
  return tasks.take(5).toList();
});

class DayPlanSlot {
  const DayPlanSlot({
    required this.task,
    required this.start,
    required this.end,
  });

  final TaskItem task;
  final DateTime start;
  final DateTime end;
}

final dayPlanProvider = Provider<List<DayPlanSlot>>((ref) {
  final suggestions = ref.watch(smartSuggestionsProvider);
  if (suggestions.isEmpty) {
    return const <DayPlanSlot>[];
  }
  final slots = <DayPlanSlot>[];
  var pointer = DateTime.now();
  for (final task in suggestions) {
    final start = pointer;
    final end = pointer.add(Duration(minutes: task.estimatedMinutes));
    slots.add(DayPlanSlot(task: task, start: start, end: end));
    pointer = end.add(const Duration(minutes: 10));
  }
  return slots;
});
