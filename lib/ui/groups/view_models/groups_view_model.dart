import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

part 'groups_view_model.freezed.dart';

class GroupsViewModel extends AsyncNotifier<GroupsState> {
  @override
  Future<GroupsState> build() async {
    final repository = ref.watch(groupRepositoryProvider);
    final groups = await repository.getGroups();

    return GroupsState(
      groups: groups,
      query: '',
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
  const GroupsState._();

  const factory GroupsState({
    required List<TaskGroup> groups,
    @Default('') String query,
  }) = _GroupsState;

  List<TaskGroup> get filteredGroups {
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return groups;
    }

    return groups
        .where((group) => group.name.toLowerCase().contains(normalizedQuery))
        .toList();
  }
}
