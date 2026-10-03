import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

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

class GroupsState {
  const GroupsState({
    required this.groups,
    this.query = '',
  });

  final List<TaskGroup> groups;
  final String query;

  List<TaskGroup> get filteredGroups {
    final normalizedQuery = query.toLowerCase().trim();

    if (normalizedQuery.isEmpty) {
      return groups;
    }

    return groups
        .where(
          (group) =>
              group.name.toLowerCase().contains(normalizedQuery),
        )
        .toList();
  }

  GroupsState copyWith({
    List<TaskGroup>? groups,
    String? query,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      query: query ?? this.query,
    );
  }
}
