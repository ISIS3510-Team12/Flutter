import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';

part 'groups_view_model.freezed.dart';

class GroupsViewModel extends AsyncNotifier<GroupsState> {
  @override
  Future<GroupsState> build() async {
    final user = await ref.watch(currentUserProvider.future);

    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final isOnline = ref.watch(isOnlineProvider);
    final repository = ref.watch(groupRepositoryProvider);
    final cache = ref.watch(groupsCacheDaoProvider);

    final result = await networkFirst<List<TaskGroup>>(
      isOnline: isOnline,
      fetch: repository.getGroups,
      save: (groups) => cache.replaceForUser(user.userId, groups),
      fallback: () => cache.findAll(user.userId),
    );

    return GroupsState(
      groups: result.value,
      fromCache: result.fromCache,
    );
  }

  void onQueryChange(String query) {
    final currentState = state;

    if (currentState is AsyncData<GroupsState>) {
      state = AsyncData(
        currentState.value.copyWith(query: query),
      );
    }
  }
}

@freezed
abstract class GroupsState with _$GroupsState {
  const factory GroupsState({
    required List<TaskGroup> groups,
    @Default('') String query,
    @Default(false) bool fromCache,
  }) = _GroupsState;

  const GroupsState._();

  List<TaskGroup> get filteredGroups {
    if (query.isEmpty) return groups;

    return groups
        .where(
          (group) => group.name.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
  }
}