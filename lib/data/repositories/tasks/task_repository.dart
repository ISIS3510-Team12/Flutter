import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  Future<List<Task>> getTasks() async {
    final groupName = await getCurrentGroupName();
    try {
      final response = await _dio.get<List<dynamic>>('/tasks');
      return response.data!
          .map(
            (json) => Task.fromJson(
              json as Map<String, dynamic>,
              groupName: groupName,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTask(String id) async {
    final groupName = await getCurrentGroupName();
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tasks/$id');
      return Task.fromJson(response.data!, groupName: groupName);
    } catch (e) {
      throw Exception('Failed to load task: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tasks',
        data: task.toCreateJson(),
      );
      final fromServer = Task.fromJson(
        response.data!,
        groupName: task.groupName,
      );
      return fromServer.copyWith(
        assignees: task.assignees,
        notes: task.notes,
        description: task.description,
        projectName: task.projectName,
        relatedTaskIds: task.relatedTaskIds,
      );
    } catch (e) {
      throw Exception('Failed to create task: $e');
    }
  }

  Future<Task> updateTask(Task updated) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/tasks/${updated.id}',
        data: updated.toUpdateJson(),
      );
      final fromServer = Task.fromJson(
        response.data!,
        groupName: updated.groupName,
      );
      return fromServer.copyWith(
        assignees: updated.assignees,
        notes: updated.notes,
        description: updated.description,
        projectName: updated.projectName,
        relatedTaskIds: updated.relatedTaskIds,
      );
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  Future<Task> updateTaskStatus(Task current, TaskStatus status) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/tasks/${current.id}/status',
        queryParameters: {'status': taskStatusToJson(status)},
      );
      final fromServer = Task.fromJson(
        response.data!,
        groupName: current.groupName,
      );
      return fromServer.copyWith(
        assignees: current.assignees,
        notes: current.notes,
        description: current.description,
        projectName: current.projectName,
        relatedTaskIds: current.relatedTaskIds,
      );
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  Future<String> getCurrentGroupName() async {
    return 'App Devs';
  }

  Future<List<String>> getGroupMembers() async {
    return const ['Cristian', 'Diego', 'Shaiel', 'Manuela'];
  }

  Future<List<String>> getProjects() async {
    return const ['Project #1', 'Project #2'];
  }

  final List<String> _groups = ['App Devs', 'Group 1', 'Group 2'];

  Future<List<String>> getGroups() async {
    return List.unmodifiable(_groups);
  }

  Future<void> addGroup(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _groups.add(name);
  }
}
