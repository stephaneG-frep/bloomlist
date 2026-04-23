import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high, critical }
enum EnergyLevel { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class SubTask {
  const SubTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  final String id;
  final String title;
  final bool isDone;

  SubTask copyWith({String? id, String? title, bool? isDone}) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  factory SubTask.fromMap(Map<dynamic, dynamic> map) {
    return SubTask(
      id: map['id'] as String,
      title: map['title'] as String,
      isDone: (map['isDone'] as bool?) ?? false,
    );
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.projectId,
    this.category,
    this.tags = const [],
    this.subTasks = const [],
    this.priority = TaskPriority.medium,
    this.energy = EnergyLevel.medium,
    this.status = TaskStatus.todo,
    this.dueDate,
    this.reminderAt,
    this.isRecurring = false,
    this.recurrenceRule,
    this.estimatedMinutes = 25,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final String? projectId;
  final String? category;
  final List<String> tags;
  final List<SubTask> subTasks;
  final TaskPriority priority;
  final EnergyLevel energy;
  final TaskStatus status;
  final DateTime? dueDate;
  final DateTime? reminderAt;
  final bool isRecurring;
  final String? recurrenceRule;
  final int estimatedMinutes;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isDone => status == TaskStatus.done;

  int get completionRatio {
    if (subTasks.isEmpty) {
      return isDone ? 100 : 0;
    }
    final done = subTasks.where((item) => item.isDone).length;
    return ((done / subTasks.length) * 100).round();
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.deepOrange;
      case TaskPriority.critical:
        return Colors.redAccent;
    }
  }

  TaskItem copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? category,
    List<String>? tags,
    List<SubTask>? subTasks,
    TaskPriority? priority,
    EnergyLevel? energy,
    TaskStatus? status,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? reminderAt,
    bool clearReminderAt = false,
    bool? isRecurring,
    String? recurrenceRule,
    bool clearRecurrenceRule = false,
    int? estimatedMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      subTasks: subTasks ?? this.subTasks,
      priority: priority ?? this.priority,
      energy: energy ?? this.energy,
      status: status ?? this.status,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceRule: clearRecurrenceRule ? null : (recurrenceRule ?? this.recurrenceRule),
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'category': category,
      'tags': tags,
      'subTasks': subTasks.map((task) => task.toMap()).toList(),
      'priority': priority.name,
      'energy': energy.name,
      'status': status.name,
      'dueDate': dueDate?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurrenceRule': recurrenceRule,
      'estimatedMinutes': estimatedMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<dynamic, dynamic> map) {
    final subTaskMaps = (map['subTasks'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<dynamic, dynamic>>();
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      projectId: map['projectId'] as String?,
      category: map['category'] as String?,
      tags: ((map['tags'] as List<dynamic>?) ?? <dynamic>[])
          .map((tag) => tag.toString())
          .toList(),
      subTasks: subTaskMaps.map(SubTask.fromMap).toList(),
      priority: TaskPriority.values.firstWhere(
        (value) => value.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      energy: EnergyLevel.values.firstWhere(
        (value) => value.name == map['energy'],
        orElse: () => EnergyLevel.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      reminderAt: map['reminderAt'] != null ? DateTime.parse(map['reminderAt'] as String) : null,
      isRecurring: (map['isRecurring'] as bool?) ?? false,
      recurrenceRule: map['recurrenceRule'] as String?,
      estimatedMinutes: (map['estimatedMinutes'] as int?) ?? 25,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt:
          map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }
}
