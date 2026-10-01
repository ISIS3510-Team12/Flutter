import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model_provider.dart';

class ProjectViewModel extends AsyncNotifier<Project?> {
  late final ProjectRepository _projectRepository;

  @override
  Future<Project?> build() async {
    _projectRepository = ref.read(projectRepositoryProvider);
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
      final project = ProjectCreate(
        name: name,
        description: description,
        deadline: deadline,
        groupId: groupId,
      );

      final createdProject =
          await _projectRepository.createProject(project);

      state = AsyncData(createdProject);

      return createdProject;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      return null;
    }
  }

  Future<void> loadProject(int projectId) async {
    state = const AsyncLoading();

    try {
      final project = await _projectRepository.getProject(projectId);

      state = AsyncData(project);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}