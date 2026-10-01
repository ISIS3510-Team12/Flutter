import 'package:team12_flutter_juggle/data/services/group/group_api_client.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_create.dart';
import 'package:team12_flutter_juggle/domain/models/group/group_update.dart';

class GroupRepository {
  GroupRepository(this._apiClient);

  final GroupApiClient _apiClient;

  Future<List<Group>> getGroups() {
    return _apiClient.fetchGroups();
  }

  Future<Group> createGroup(GroupCreate group) {
    return _apiClient.createGroup(group);
  }

  Future<Group> updateGroup(int groupId, GroupUpdate group,) {
    return _apiClient.updateGroup(
      groupId,
      group,
    );
  }

  Future<Group> getGroup(int groupId) {
    return _apiClient.fetchGroup(groupId);
  }
}