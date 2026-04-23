import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../projects/domain/project_item.dart';
import '../../projects/state/projects_controller.dart';
import '../domain/task_item.dart';
import '../state/tasks_controller.dart';

class TaskEditorScreen extends ConsumerStatefulWidget {
  const TaskEditorScreen({super.key, this.taskId});

  final String? taskId;

  @override
  ConsumerState<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends ConsumerState<TaskEditorScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _recurrenceController = TextEditingController(text: 'every Monday');
  final _estimateController = TextEditingController(text: '25');

  TaskItem? _existingTask;
  String? _projectId;
  TaskPriority _priority = TaskPriority.medium;
  EnergyLevel _energy = EnergyLevel.medium;
  DateTime? _dueDate;
  DateTime? _reminderAt;
  bool _isRecurring = false;
  final List<SubTask> _subTasks = <SubTask>[];

  @override
  void initState() {
    super.initState();
    final id = widget.taskId;
    if (id == null) {
      return;
    }
    final candidates = ref.read(allTasksProvider).where((item) => item.id == id);
    final task = candidates.isEmpty ? null : candidates.first;
    if (task == null) {
      return;
    }
    _existingTask = task;
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _tagsController.text = task.tags.join(', ');
    _categoryController.text = task.category ?? '';
    _priority = task.priority;
    _energy = task.energy;
    _projectId = task.projectId;
    _dueDate = task.dueDate;
    _reminderAt = task.reminderAt;
    _isRecurring = task.isRecurring;
    _recurrenceController.text = task.recurrenceRule ?? 'every Monday';
    _estimateController.text = task.estimatedMinutes.toString();
    _subTasks
      ..clear()
      ..addAll(task.subTasks);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    _recurrenceController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool reminder}) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 3650)),
      initialDate: reminder ? (_reminderAt ?? now) : (_dueDate ?? now),
    );
    if (!mounted || pickedDate == null) {
      return;
    }
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (!mounted || pickedTime == null) {
      return;
    }
    final dateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    setState(() {
      if (reminder) {
        _reminderAt = dateTime;
      } else {
        _dueDate = dateTime;
      }
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      return;
    }
    final tags = _tagsController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    final estimate = int.tryParse(_estimateController.text.trim()) ?? 25;
    final controller = ref.read(tasksControllerProvider.notifier);

    if (_existingTask == null) {
      await controller.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        projectId: _projectId,
        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        tags: tags,
        priority: _priority,
        energy: _energy,
        dueDate: _dueDate,
        reminderAt: _reminderAt,
        isRecurring: _isRecurring,
        recurrenceRule: _isRecurring ? _recurrenceController.text.trim() : null,
        estimatedMinutes: estimate,
        subTasks: _subTasks,
      );
    } else {
      await controller.upsertTask(
        _existingTask!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          projectId: _projectId,
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
          tags: tags,
          priority: _priority,
          energy: _energy,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          reminderAt: _reminderAt,
          clearReminderAt: _reminderAt == null,
          isRecurring: _isRecurring,
          recurrenceRule: _isRecurring ? _recurrenceController.text.trim() : null,
          clearRecurrenceRule: !_isRecurring,
          estimatedMinutes: estimate,
          subTasks: _subTasks,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsControllerProvider).valueOrNull ?? const <ProjectItem>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'Nouvelle tâche' : 'Modifier la tâche'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Enregistrer')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre')),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            initialValue: _projectId,
            decoration: const InputDecoration(labelText: 'Projet'),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('Aucun projet')),
              ...projects.map(
                (project) => DropdownMenuItem<String?>(value: project.id, child: Text(project.name)),
              ),
            ],
            onChanged: (value) => setState(() => _projectId = value),
          ),
          const SizedBox(height: 12),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Catégorie')),
          const SizedBox(height: 12),
          TextField(
            controller: _tagsController,
            decoration: const InputDecoration(labelText: 'Tags (séparés par des virgules)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TaskPriority>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priorité'),
            items: TaskPriority.values
                .map((value) => DropdownMenuItem(value: value, child: Text(value.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _priority = value);
              }
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<EnergyLevel>(
            initialValue: _energy,
            decoration: const InputDecoration(labelText: 'Niveau d\'énergie requis'),
            items: EnergyLevel.values
                .map((value) => DropdownMenuItem(value: value, child: Text(value.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _energy = value);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _estimateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Temps estimé (minutes)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(reminder: false),
                  icon: const Icon(Icons.event_rounded),
                  label: Text(_dueDate == null ? 'Échéance' : _dueDate.toString().substring(0, 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(reminder: true),
                  icon: const Icon(Icons.alarm_rounded),
                  label: Text(_reminderAt == null ? 'Rappel' : _reminderAt.toString().substring(0, 16)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _isRecurring,
            title: const Text('Tâche récurrente'),
            subtitle: const Text('Ex: every Monday, every day'),
            onChanged: (value) => setState(() => _isRecurring = value),
          ),
          if (_isRecurring)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _recurrenceController,
                decoration: const InputDecoration(labelText: 'Règle de récurrence'),
              ),
            ),
          const SizedBox(height: 12),
          Text('Sous-tâches', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._subTasks.map(
            (subTask) => ListTile(
              leading: Checkbox(
                value: subTask.isDone,
                onChanged: (value) {
                  setState(() {
                    final index = _subTasks.indexWhere((item) => item.id == subTask.id);
                    _subTasks[index] = subTask.copyWith(isDone: value ?? false);
                  });
                },
              ),
              title: Text(subTask.title),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => setState(() => _subTasks.removeWhere((item) => item.id == subTask.id)),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final controller = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nouvelle sous-tâche'),
                  content: TextField(controller: controller, autofocus: true),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              );
              if (result == null || result.isEmpty) {
                return;
              }
              setState(() {
                _subTasks.add(SubTask(id: const Uuid().v4(), title: result));
              });
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ajouter une sous-tâche'),
          ),
        ],
      ),
    );
  }
}
