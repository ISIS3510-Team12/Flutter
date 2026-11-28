import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_update.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

class EditProjectState {
  final Project project;
  final TaskGroup group;
  final bool isSaving;

  const EditProjectState({
    required this.project,
    required this.group,
    this.isSaving = false,
  });

  EditProjectState copyWith({
    Project? project,
    TaskGroup? group,
    bool? isSaving,
  }) {
    return EditProjectState(
      project: project ?? this.project,
      group: group ?? this.group,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class EditProjectViewModel extends AsyncNotifier<EditProjectState> {
  EditProjectViewModel({
    required this.projectId,
    required this.groupId,
  });

  final int projectId;
  final int groupId;

  Object? lastFailure;

  @override
  Future<EditProjectState> build() async {
    return loadEditData();
  }

  Future<EditProjectState> loadEditData() async {
    try {
      final projectRepository = ref.read(projectRepositoryProvider);
      final groupRepository = ref.read(groupRepositoryProvider);

      // Las dos consultas comienzan antes de esperar sus resultados.
      final results = await (
        projectRepository.getProject(projectId),
        groupRepository.getGroup(groupId),
      ).wait;

      return EditProjectState(
        project: results.$1,
        group: results.$2,
      );
    } catch (error, stackTrace) {
      lastFailure = error;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<bool> updateProject({
    required String name,
    required String description,
    required DateTime deadline,
  }) async {
    final currentState = state.asData?.value;

    if (currentState == null || currentState.isSaving) {
      return false;
    }

    lastFailure = null;

    if (!ref.read(isOnlineProvider)) {
      lastFailure = const NetworkUnavailableException();
      return false;
    }

    state = AsyncData(
      currentState.copyWith(isSaving: true),
    );

    try {
      final repository = ref.read(projectRepositoryProvider);

      final updatedProject = await repository.updateProject(
        projectId,
        ProjectUpdate(
          name: name,
          description: description,
          deadline: deadline,
        ),
      );

      if (!ref.mounted) return true;

      state = AsyncData(
        currentState.copyWith(
          project: updatedProject,
          isSaving: false,
        ),
      );

      return true;
    } catch (error) {
      if (!ref.mounted) return false;

      lastFailure = error;

      state = AsyncData(
        currentState.copyWith(isSaving: false),
      );

      return false;
    }
  }
}
