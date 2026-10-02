import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class ProjectDetailViewModel extends AsyncNotifier<ProjectDetailState> {
  ProjectDetailViewModel(this.projectId);

  final int projectId;

  @override
  Future<ProjectDetailState> build() async {
    final projectRepository = ref.watch(projectRepositoryProvider);
    final taskRepository = ref.watch(taskRepositoryProvider);

    final project = await projectRepository.getProject(projectId);
    final allTasks = await taskRepository.getAllTasks();

    if (!ref.mounted) {
      throw StateError('Project detail provider was disposed.');
    }

    final projectTasks = allTasks
        .where((task) => task.projectId == projectId)
        .toList();

    return ProjectDetailState(project: project, tasks: projectTasks);
  }
}

class ProjectCreateViewModel extends AsyncNotifier<Project?> {
  @override
  Future<Project?> build() async {
    return null;
  }

  Future<Project?> createProject({
    required String name,
    required String description,
    required DateTime deadline,
    required int groupId,
  }) async {
    state = const AsyncLoading();

    try {
      final projectRepository = ref.read(projectRepositoryProvider);

      final projectData = ProjectCreate(
        name: name,
        description: description,
        deadline: deadline,
        groupId: groupId,
      );

      final createdProject = await projectRepository.createProject(projectData);

      if (!ref.mounted) {
        return createdProject;
      }

      state = AsyncData(createdProject);
      return createdProject;
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return null;
      }

      state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

class ProjectDetailState {
  const ProjectDetailState({required this.project, required this.tasks});

  final Project project;
  final List<Task> tasks;
}
