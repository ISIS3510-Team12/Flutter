import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/selected_task_group_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/task_list_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'tasks_viewmodel.freezed.dart';

@freezed
abstract class TasksState with _$TasksState {
  const TasksState._();

  const factory TasksState({
    required TaskGroup? group,
    required List<TaskGroup> groups,
    required List<Task> tasks,
    required String query,
    @Default(false) bool fromCache,
    @Default({}) Set<int> loadedGroupIds,
    @Default(true) bool groupLoaded,
  }) = _TasksState;

  String get groupName => group?.name ?? 'No group';

  bool isLoaded(TaskGroup group) => loadedGroupIds.contains(group.id);

  List<TaskListEntry> myEntries(List<PendingOp> pending) =>
      _entries(pending, mine: true);

  List<TaskListEntry> groupEntries(List<PendingOp> pending) =>
      _entries(pending, mine: false);

  List<TaskListEntry> _entries(List<PendingOp> pending, {required bool mine}) {
    final groupId = group?.id;
    final queued = [
      if (groupId != null)
        for (final op in pending)
          if (op.isTask && op.task.groupId == groupId) PendingTaskEntry(op),
    ];
    final uploadedIds = {for (final entry in queued) ?entry.op.serverTaskId};
    final entries = <TaskListEntry>[
      for (final task in tasks)
        if (task.isMine == mine &&
            _matchesQuery(task) &&
            !uploadedIds.contains(task.id))
          SyncedTaskEntry(task),
      for (final entry in queued)
        if (entry.task.isMine == mine && _matchesQuery(entry.task)) entry,
    ];
    return entries..sort((a, b) => _compare(a.task, b.task));
  }

  int _compare(Task a, Task b) {
    final byDeadline = a.deadline.compareTo(b.deadline);
    if (byDeadline != 0) return byDeadline;
    if (a.isPriority != b.isPriority) return a.isPriority ? -1 : 1;
    final idA = int.tryParse(a.id) ?? 0;
    final idB = int.tryParse(b.id) ?? 0;
    return idA.compareTo(idB);
  }

  bool _matchesQuery(Task task) {
    if (query.isEmpty) return true;
    return task.title.toLowerCase().contains(query.toLowerCase());
  }
}

enum SwitchGroupResult { switched, unavailable, failed }

String groupNotLoadedMessage(String groupName) =>
    "$groupName hasn't been loaded yet; connect to load it.";

class TasksViewModel extends AsyncNotifier<TasksState> {
  String? _userId;

  GroupsCacheDao get _groupsCache => ref.read(groupsCacheDaoProvider);

  TasksCacheDao get _tasksCache => ref.read(tasksCacheDaoProvider);

  @override
  Future<TasksState> build() async {
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final groupRepository = ref.watch(groupRepositoryProvider);
    ref.watch(taskRepositoryProvider);
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw StateError('User is not logged in');
    final userId = _userId = user.userId;
    final online = ref.read(isOnlineProvider);
    final groups = await networkFirst(
      isOnline: online,
      fetch: groupRepository.getGroups,
      save: (groups) => _groupsCache.replaceForUser(userId, groups),
      fallback: () => _groupsCache.findAll(userId),
    );
    final loaded = await _tasksCache.loadedGroupIds(userId);
    final group = selectedGroup.resolve(groups.value);
    if (group == null) {
      return TasksState(
        group: null,
        groups: groups.value,
        tasks: const [],
        query: '',
        fromCache: groups.fromCache,
        loadedGroupIds: loaded,
      );
    }
    try {
      final tasks = await _loadTasks(userId, group, online: online);
      return TasksState(
        group: group,
        groups: groups.value,
        tasks: tasks.value,
        query: '',
        fromCache: groups.fromCache || tasks.fromCache,
        loadedGroupIds: {...loaded, group.id},
      );
    } catch (error) {
      if (!isOfflineFailure(error)) rethrow;
      final fallback = groups.value
          .where((candidate) => loaded.contains(candidate.id))
          .firstOrNull;
      final cached = fallback == null
          ? null
          : await _tasksCache.findPendingForGroup(userId, fallback.id);
      if (fallback != null && cached != null) {
        return TasksState(
          group: fallback,
          groups: groups.value,
          tasks: cached,
          query: '',
          fromCache: true,
          loadedGroupIds: loaded,
        );
      }
      return TasksState(
        group: group,
        groups: groups.value,
        tasks: const [],
        query: '',
        fromCache: true,
        loadedGroupIds: loaded,
        groupLoaded: false,
      );
    }
  }

  Future<CacheRead<List<Task>>> _loadTasks(
    String userId,
    TaskGroup group, {
    required bool online,
  }) {
    return networkFirst(
      isOnline: online,
      fetch: () => ref.read(taskRepositoryProvider).getGroupTasks(group),
      save: (tasks) => _tasksCache.replaceForGroup(userId, group.id, tasks),
      fallback: () => _tasksCache.findPendingForGroup(userId, group.id),
    );
  }

  void updateQuery(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: value));
  }

  Future<SwitchGroupResult> switchGroup(TaskGroup group) async {
    final current = state.value;
    final userId = _userId;
    if (current == null || userId == null) return SwitchGroupResult.failed;
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    try {
      final tasks = await _loadTasks(
        userId,
        group,
        online: ref.read(isOnlineProvider),
      );
      if (!ref.mounted) return SwitchGroupResult.failed;
      selectedGroup.select(group.id);
      state = AsyncData(
        current.copyWith(
          group: group,
          tasks: tasks.value,
          fromCache: tasks.fromCache,
          loadedGroupIds: {...current.loadedGroupIds, group.id},
          groupLoaded: true,
        ),
      );
      return SwitchGroupResult.switched;
    } catch (error) {
      return isOfflineFailure(error)
          ? SwitchGroupResult.unavailable
          : SwitchGroupResult.failed;
    }
  }

  Future<void> createGroup(String name) async {
    await ref.read(groupRepositoryProvider).createGroup(name);
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }
}
