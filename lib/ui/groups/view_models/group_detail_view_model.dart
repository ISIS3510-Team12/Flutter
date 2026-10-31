import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/network/parallel_wait.dart';

part 'group_detail_view_model.freezed.dart';

class GroupDetailViewModel extends AsyncNotifier<GroupDetailState> {
  GroupDetailViewModel(this.groupId);

  final int groupId;

  @override
  Future<GroupDetailState> build() async {
    final me = (await ref.watch(currentUserProvider.future))!;
    final userId = me.userId;
    final isOnline = ref.watch(isOnlineProvider);

    final groupRepository = ref.watch(groupRepositoryProvider);
    final projectRepository = ref.watch(projectRepositoryProvider);
    final groupsCache = ref.watch(groupsCacheDaoProvider);
    final projectsCache = ref.watch(projectsCacheDaoProvider);

    final (groupResult, projectsResult) = await waitBoth(
      networkFirst<TaskGroup>(
        isOnline: isOnline,
        fetch: () => groupRepository.getGroup(groupId),
        save: (group) => groupsCache.save(userId, group),
        fallback: () => groupsCache.watchGroup(userId, groupId).first,
      ),
      networkFirst<List<Project>>(
        isOnline: isOnline,
        fetch: () => projectRepository.getGroupProjects(groupId),
        save: (projects) =>
            projectsCache.replaceForGroup(userId, groupId, projects),
        fallback: () => projectsCache.findForGroup(userId, groupId),
      ),
    );

    if (!ref.mounted) {
      throw StateError('Group detail provider was disposed.');
    }

    return GroupDetailState(
      group: groupResult.value,
      projects: projectsResult.value,
      fromCache: groupResult.fromCache || projectsResult.fromCache,
    );
  }
}

@freezed
abstract class GroupDetailState with _$GroupDetailState {
  const factory GroupDetailState({
    required TaskGroup group,
    required List<Project> projects,
    @Default(false) bool fromCache,
  }) = _GroupDetailState;
}
