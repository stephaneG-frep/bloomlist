import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/storage_providers.dart';
import '../domain/project_item.dart';

class ProjectsController extends AsyncNotifier<List<ProjectItem>> {
  final _uuid = const Uuid();

  @override
  Future<List<ProjectItem>> build() async {
    return ref.read(localDataSourceProvider).loadProjects();
  }

  Future<void> createProject({required String name, required int colorValue, required int iconCodePoint}) async {
    final project = ProjectItem(
      id: _uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      colorValue: colorValue,
      iconCodePoint: iconCodePoint,
    );
    await ref.read(localDataSourceProvider).saveProject(project);
    state = AsyncData([...(state.value ?? <ProjectItem>[]), project]);
  }

  Future<void> deleteProject(String projectId) async {
    await ref.read(localDataSourceProvider).removeProject(projectId);
    state = AsyncData((state.value ?? <ProjectItem>[]).where((p) => p.id != projectId).toList());
  }
}

final projectsControllerProvider =
    AsyncNotifierProvider<ProjectsController, List<ProjectItem>>(ProjectsController.new);
