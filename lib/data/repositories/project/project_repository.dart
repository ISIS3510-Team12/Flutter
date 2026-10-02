import 'package:dio/dio.dart';

import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_update.dart';

class ProjectRepository {
  ProjectRepository(this._dio);

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

  Future<List<Project>> getGroupProjects(int groupId) async {
    final response = await _dio.get<List<dynamic>>('/projects/group/$groupId');

    return response.data!
        .map((json) => Project.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Project> updateProject(int projectId, ProjectUpdate update) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/projects/$projectId',
      data: update.toJson(),
    );

    return Project.fromJson(response.data!);
  }

  Future<void> deleteProject(int projectId) async {
    await _dio.delete<void>('/projects/$projectId');
  }
}
