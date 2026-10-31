import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/project_tasks_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/domain/models/project/deadline_prediction.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

part 'project_view_model.freezed.dart';

class ProjectDetailViewModel extends AsyncNotifier<ProjectDetailState> {
  ProjectDetailViewModel(this.projectId);

  final int projectId;

  @override
  Future<ProjectDetailState> build() async {
    final me = (await ref.watch(currentUserProvider.future))!;
    final userId = me.userId;
    final isOnline = ref.watch(isOnlineProvider);

    final projectRepository = ref.watch(projectRepositoryProvider);
    final taskRepository = ref.watch(taskRepositoryProvider);

    final projectsCache = ref.watch(projectsCacheDaoProvider);
    final tasksCache = ref.watch(projectTasksCacheDaoProvider);

    final (projectResult, tasksResult) = await (
      networkFirst<Project>(
        isOnline: isOnline,
        fetch: () => projectRepository.getProject(projectId),
        save: (project) => projectsCache.save(userId, project),
        fallback: () => projectsCache.findProject(userId, projectId),
      ),
      networkFirst<List<Task>>(
        isOnline: isOnline,
        fetch: () => taskRepository.getProjectTasks(projectId),
        save: (tasks) =>
            tasksCache.replaceForProject(userId, projectId, tasks),
        fallback: () => tasksCache.findForProject(userId, projectId),
      ),
    ).wait;

    if (!ref.mounted) {
      throw StateError('Project detail provider was disposed.');
    }

    DeadlinePrediction? prediction;

    if (isOnline) {
      try {
        prediction = await projectRepository.getDeadlinePrediction(projectId);
      } catch (error) {
        if (!isOfflineFailure(error)) rethrow;
      }
    }

    if (!ref.mounted) {
      throw StateError('Project detail provider was disposed.');
    }

    return ProjectDetailState(
      project: projectResult.value,
      tasks: tasksResult.value,
      prediction: prediction,
      fromCache: projectResult.fromCache || tasksResult.fromCache,
    );
  }
}

class ProjectCreateViewModel extends AsyncNotifier<Project?> {
  @override
  Future<Project?> build() async => null;

  Future<Project?> createProject({
    required String name,
    required String description,
    required DateTime deadline,
    required int groupId,
  }) async {
    if (state.isLoading) return null;

    if (!ref.read(isOnlineProvider)) {
      state = AsyncError(
        const NetworkUnavailableException(),
        StackTrace.current,
      );
      return null;
    }

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

      if (!ref.mounted) return createdProject;

      state = AsyncData(createdProject);
      return createdProject;
    } catch (error, stackTrace) {
      if (!ref.mounted) return null;

      final friendlyError = switch (error) {
        NetworkUnavailableException() => error,
        ServiceUnavailableException() => error,
        _ => Exception(
            'Could not create the project. Please try again.',
          ),
      };

      state = AsyncError(friendlyError, stackTrace);
      return null;
    }
  }
}

@freezed
abstract class ProjectDetailState with _$ProjectDetailState {
  const factory ProjectDetailState({
    required Project project,
    required List<Task> tasks,
    required DeadlinePrediction? prediction,
    @Default(false) bool fromCache,
  }) = _ProjectDetailState;
}
