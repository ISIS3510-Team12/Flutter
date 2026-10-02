import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_create.dart';
import 'package:team12_flutter_juggle/domain/models/project/project_update.dart';

class ProjectRepository {
  ProjectRepository(this._dio);

  final Dio _dio;

  Future<Project> createProject(ProjectCreate project) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/projects',
        data: project.toJson(),
      );
      return Project.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to create project: $e');
    }
  }

  Future<Project> getProject(int projectId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/projects/$projectId',
      );
      return Project.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to load project: $e');
    }
  }

  Future<List<Project>> getGroupProjects(int groupId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/projects/group/$groupId',
      );
      return response.data!
          .map((json) => Project.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load projects: $e');
    }
  }

  Future<Project> updateProject(int projectId, ProjectUpdate update) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/projects/$projectId',
        data: update.toJson(),
      );
      return Project.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to update project: $e');
    }
  }

  Future<void> deleteProject(int projectId) async {
    try {
      await _dio.delete<void>('/projects/$projectId');
    } catch (e) {
      throw Exception('Failed to delete project: $e');
    }
  }
}
