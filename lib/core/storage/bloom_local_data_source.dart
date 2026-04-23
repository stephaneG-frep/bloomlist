import 'package:hive_flutter/hive_flutter.dart';

import '../../features/projects/domain/project_item.dart';
import '../../features/settings/domain/app_settings.dart';
import '../../features/tasks/domain/task_item.dart';

class BloomLocalDataSource {
  static const _tasksBoxName = 'bloom_tasks';
  static const _projectsBoxName = 'bloom_projects';
  static const _settingsBoxName = 'bloom_settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(_tasksBoxName),
      Hive.openBox<Map>(_projectsBoxName),
      Hive.openBox<Map>(_settingsBoxName),
    ]);
  }

  Box<Map> get _tasksBox => Hive.box<Map>(_tasksBoxName);
  Box<Map> get _projectsBox => Hive.box<Map>(_projectsBoxName);
  Box<Map> get _settingsBox => Hive.box<Map>(_settingsBoxName);

  Future<List<TaskItem>> loadTasks() async {
    return _tasksBox.values.map((value) => TaskItem.fromMap(value)).toList();
  }

  Future<void> saveTask(TaskItem task) async {
    await _tasksBox.put(task.id, task.toMap());
  }

  Future<void> removeTask(String id) async {
    await _tasksBox.delete(id);
  }

  Future<List<ProjectItem>> loadProjects() async {
    final items = _projectsBox.values.map((value) => ProjectItem.fromMap(value)).toList();
    if (items.isNotEmpty) {
      return items;
    }
    final defaultProject = ProjectItem(
      id: 'inbox',
      name: 'Inbox',
      createdAt: DateTime.now(),
      colorValue: 0xFF3B82F6,
      iconCodePoint: 0xe8b8,
    );
    await saveProject(defaultProject);
    return [defaultProject];
  }

  Future<void> saveProject(ProjectItem project) async {
    await _projectsBox.put(project.id, project.toMap());
  }

  Future<void> removeProject(String id) async {
    await _projectsBox.delete(id);
  }

  Future<AppSettings> loadSettings() async {
    final raw = _settingsBox.get('app_settings');
    if (raw == null) {
      return const AppSettings();
    }
    return AppSettings.fromMap(raw);
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('app_settings', settings.toMap());
  }
}
