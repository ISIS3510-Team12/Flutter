import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';

class ProjectApiClient {
  ProjectApiClient(this._dio);

  final Dio _dio;

  Future<Project> createProject(ProjectCreate project) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/projects',
      data: project.toJson(),
    );

    return Project.fromJson(response.data!);
  }

  Future<Project> getProject(int projectId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/projects/$projectId',
    );

    return Project.fromJson(response.data!);
  }
}