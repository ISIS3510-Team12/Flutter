import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model_provider.dart';

class ProjectViewModel extends AsyncNotifier<ProjectDetailState?> {
  @override
  Future<ProjectDetailState?> build() async {
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

      final createdProject =
          await projectRepository.createProject(projectData);

      state = AsyncData(
        ProjectDetailState(
          project: createdProject,
          tasks: const [],
        ),
      );

      return createdProject;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<void> loadProject(int projectId) async {
    state = const AsyncLoading();

    try {
      final projectRepository = ref.read(projectRepositoryProvider);
      final taskRepository = ref.read(taskRepositoryProvider);

      final project = await projectRepository.getProject(projectId);
      final allTasks = await taskRepository.getAllTasks();

      final projectTasks = allTasks
          .where((task) => task.projectId == projectId)
          .toList();

      state = AsyncData(
        ProjectDetailState(
          project: project,
          tasks: projectTasks,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class ProjectDetailState {
  const ProjectDetailState({
    required this.project,
    required this.tasks,
  });

  final Project project;
  final List<Task> tasks;
}