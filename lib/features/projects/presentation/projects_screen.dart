import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/bloom_shell_background.dart';
import '../state/projects_controller.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsControllerProvider).valueOrNull ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projets'),
        actions: [
          IconButton(
            onPressed: () async {
              final controller = TextEditingController();
              final result = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Nouveau projet'),
                  content: TextField(controller: controller, autofocus: true),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, controller.text.trim()),
                      child: const Text('Créer'),
                    ),
                  ],
                ),
              );
              if (result == null || result.isEmpty) {
                return;
              }
              await ref.read(projectsControllerProvider.notifier).createProject(
                    name: result,
                    colorValue: Colors.primaries[result.length % Colors.primaries.length].toARGB32(),
                    iconCodePoint: Icons.folder_rounded.codePoint,
                  );
            },
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: BloomShellBackground(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: project.color, child: Icon(project.icon, color: Colors.white)),
                title: Text(project.name),
                subtitle: Text('Créé le ${project.createdAt.toString().substring(0, 10)}'),
                trailing: project.id == 'inbox'
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () => ref.read(projectsControllerProvider.notifier).deleteProject(project.id),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
