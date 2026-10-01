import 'package:dio/dio.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_create.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_update.dart';

class GroupApiClient {
  GroupApiClient(this._dio);

  final Dio _dio;

  Future<List<Group>> fetchGroups() async {
    final response = await _dio.get<List<dynamic>>(
      '/groups',
    );

    return response.data!
        .map(
          (json) => Group.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<Group> createGroup(GroupCreate group) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/groups',
      data: group.toJson(),
    );

    return Group.fromJson(response.data!);
  }

  Future<Group> updateGroup(
    int groupId,
    GroupUpdate group,
  ) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/groups/$groupId',
      data: group.toJson(),
    );

    return Group.fromJson(response.data!);
  }

  Future<Group> fetchGroup(int groupId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/groups/$groupId',
    );

    return Group.fromJson(response.data!);
  }
}