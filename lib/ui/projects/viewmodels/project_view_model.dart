import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';

class ProjectViewModel extends ChangeNotifier {
  ProjectViewModel({
    required ProjectRepository projectRepository,
  }) : _projectRepository = projectRepository;

  final ProjectRepository _projectRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<Project?> createProject({
    required String name,
    required String description,
    required DateTime deadline,
    required int groupId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final project = ProjectCreate(
        name: name,
        description: description,
        deadline: deadline,
        groupId: groupId,
      );

      final createdProject =
          await _projectRepository.createProject(project);

      return createdProject;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}