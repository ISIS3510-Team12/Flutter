import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_create.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class GroupRepository {
  GroupRepository(this._dio);

  final Dio _dio;

  Future<List<TaskGroup>> getGroups() async {
    try {
      final response = await _dio.get<List<dynamic>>('/groups');
      return response.data!
          .map(
            (json) => TaskGroup.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load groups: $e');
    }
  }

  Future<TaskGroup> getGroup(int groupId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/groups/$groupId',
      );
      return TaskGroup.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to load group: $e');
    }
  }

  Future<TaskGroup> createGroup(
    String name, {
    String? description,
    List<String> userIds = const [],
  }) async {
    try {
      final group = GroupCreate(
        name: name,
        description: description ?? name,
        userIds: userIds,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        '/groups',
        data: group.toJson(),
      );

      return TaskGroup.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to create group: $e');
    }
  }


  Future<TaskGroup> updateGroup(
    int groupId, {
    String? name,
    String? description,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/groups/$groupId',
        data: {
          'name': ?name,
          'description': ?description,
        },
      );

      return TaskGroup.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to update group: $e');
    }
  }

  Future<void> deleteGroup(int groupId) async {
    try {
      await _dio.delete<void>('/groups/$groupId');
    } catch (e) {
      throw Exception('Failed to delete group: $e');
    }
  }

  Future<TaskGroup> addMember(int groupId, String email) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/groups/$groupId/members',
        data: {'email': email},
      );

      return TaskGroup.fromJson(response.data!);
    } catch (e) {
      throw Exception('Failed to add member: $e');
    }
  }

  Future<void> leaveGroup(int groupId) async {
    try {
      await _dio.delete<void>('/groups/$groupId/members/me');
    } catch (e) {
      throw Exception('Failed to leave group: $e');
    }
  }
}
