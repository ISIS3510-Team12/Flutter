import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/ui/core/utils/photo_upload_exception.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class TaskRepository {
  TaskRepository(this._dio);

  final Dio _dio;

  Future<List<Task>> getGroupTasks(TaskGroup group) async {
    try {
      final own = await _dio.get<List<dynamic>>('/tasks/own/${group.id}');
      final others = await _dio.get<List<dynamic>>('/tasks/group/${group.id}');
      return [
        for (final json in own.data!)
          Task.fromJson(json as Map<String, dynamic>, groupName: group.name),
        for (final json in others.data!)
          Task.fromJson(
            json as Map<String, dynamic>,
            groupName: group.name,
            isMine: false,
          ),
      ];
    } catch (e) {
      throw Exception('Failed to load group tasks: $e');
    }
  }

  Future<List<Task>> getAllTasks({
    bool mine = false,
    bool priority = false,
    int? dueWithinDays,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/tasks/all',
        queryParameters: {
          'mine': mine,
          'priority': priority,
          'due_within_days': ?dueWithinDays,
        },
      );
      final groups = await _loadGroupNames();
      return response.data!.map((json) {
        final map = json as Map<String, dynamic>;
        return Task.fromJson(
          map,
          groupName: groups[map['group_id']] ?? '',
          isMine: mine,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Map<int, String>> _loadGroupNames() async {
    final response = await _dio.get<List<dynamic>>('/groups');
    return {
      for (final json in response.data!)
        (json as Map<String, dynamic>)['id'] as int: json['name'] as String,
    };
  }

  Future<List<Task>> getProjectTasks(int projectId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<Task> getTask(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tasks/$id');
      final json = response.data!;
      final groups = await _loadGroupNames();
      return Task.fromJson(json, groupName: groups[json['group_id']] ?? '');
    } catch (e) {
      throw Exception('Failed to load task: $e');
    }
  }

  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tasks',
        data: {
          ...task.toCreateJson(),
          'project_id': ?task.projectId,
          'group_id': ?task.groupId,
          'related_task_ids': task.relatedTaskIds.map(int.parse).toList(),
        },
      );
      final fromServer = Task.fromJson(
        response.data!,
        groupName: task.groupName,
      );
      return fromServer.copyWith(
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
        data: {...updated.toUpdateJson(), 'project_id': ?updated.projectId},
      );
      final fromServer = Task.fromJson(
        response.data!,
        groupName: updated.groupName,
      );
      return fromServer.copyWith(
        description: updated.description,
        projectName: updated.projectName,
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
        description: current.description,
        projectName: current.projectName,
      );
    } catch (e) {
      throw Exception('Failed to update task status: $e');
    }
  }

  Future<void> uploadTaskPhoto(String taskId, String path) async {
    try {
      await _dio.put<void>(
        '/tasks/$taskId/photo',
        data: FormData.fromMap({
          'file': await MultipartFile.fromFile(
            path,
            filename: 'photo.${_photoSubtype(path)}',
            contentType: DioMediaType('image', _photoSubtype(path)),
          ),
        }),
      );
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 413:
          throw const PhotoUploadException(
            'The photo is too large. The maximum size is 5 MB.',
          );
        case 415:
          throw const PhotoUploadException(
            'Only JPEG, PNG, WebP or HEIC photos are allowed.',
          );
        default:
          throw const PhotoUploadException('The photo could not be uploaded.');
      }
    }
  }

  Future<Uint8List?> getTaskPhoto(String taskId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/tasks/$taskId/photo',
        options: Options(
          responseType: ResponseType.bytes,
          validateStatus: (status) => status == 200 || status == 404,
        ),
      );
      if (response.statusCode == 404) return null;
      return Uint8List.fromList(response.data!);
    } catch (e) {
      throw Exception('Failed to load photo: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete('/tasks/$id');
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }
}

String _photoSubtype(String path) {
  final extension = path.split('.').last.toLowerCase();
  switch (extension) {
    case 'png':
      return 'png';
    case 'webp':
      return 'webp';
    case 'heic':
      return 'heic';
    case 'heif':
      return 'heif';
    default:
      return 'jpeg';
  }
}
