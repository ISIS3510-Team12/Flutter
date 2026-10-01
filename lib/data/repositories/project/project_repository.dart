import 'package:team12_flutter_juggle/data/services/project/project_api_client.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';

class ProjectRepository {
  ProjectRepository(this._apiClient);

  final ProjectApiClient _apiClient;

  Future<Project> createProject(ProjectCreate project) {
    return _apiClient.createProject(project);
  }
}