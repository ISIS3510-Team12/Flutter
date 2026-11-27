import 'dart:async';

import 'package:flutter/foundation.dart';
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
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/next_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/selected_task_group_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/task_list_entry.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_view_mode_provider.dart';
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
    @Default(false) bool completedUnavailable,
    @Default([]) List<String> movedTaskIds,
  }) = _TasksState;

  String get groupName => group?.name ?? 'No group';

  bool isLoaded(TaskGroup group) => loadedGroupIds.contains(group.id);

  List<TaskListEntry> myEntries(List<PendingOp> pending) => _entries(
    pending,
    (task) => task.isMine && task.status != TaskStatus.done,
  );

  List<TaskListEntry> groupEntries(List<PendingOp> pending) => _entries(
    pending,
    (task) => !task.isMine && task.status != TaskStatus.done,
  );

  List<TaskListEntry> boardEntries(TaskStatus status, List<PendingOp> pending) {
    final entries = _entries(pending, (task) => task.status == status);
    return [
      for (final id in movedTaskIds)
        ...entries.where((entry) => entry.task.id == id),
      ...entries.where((entry) => !movedTaskIds.contains(entry.task.id)),
    ];
  }

  List<TaskListEntry> _entries(
    List<PendingOp> pending,
    bool Function(Task task) include,
  ) {
    final groupId = group?.id;
    final queued = [
      if (groupId != null)
        for (final op in pending)
          if (op.isTask && op.task.groupId == groupId) PendingTaskEntry(op),
    ];
    final uploadedIds = {for (final entry in queued) ?entry.op.serverTaskId};
    final entries = <TaskListEntry>[
      for (final task in tasks)
        if (include(task) &&
            _matchesQuery(task) &&
            !uploadedIds.contains(task.id))
          SyncedTaskEntry(task),
      for (final entry in queued)
        if (include(entry.task) && _matchesQuery(entry.task)) entry,
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

enum MoveTaskResult { moved, offline, failed }

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
      return await _withBoardData(
        userId,
        TasksState(
          group: group,
          groups: groups.value,
          tasks: tasks.value,
          query: '',
          fromCache: groups.fromCache || tasks.fromCache,
          loadedGroupIds: {...loaded, group.id},
        ),
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
        return await _withBoardData(
          userId,
          TasksState(
            group: fallback,
            groups: groups.value,
            tasks: cached,
            query: '',
            fromCache: true,
            loadedGroupIds: loaded,
          ),
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
      final next = await _withBoardData(
        userId,
        current.copyWith(
          group: group,
          tasks: tasks.value,
          fromCache: tasks.fromCache,
          loadedGroupIds: {...current.loadedGroupIds, group.id},
          groupLoaded: true,
        ),
      );
      if (!ref.mounted) return SwitchGroupResult.failed;
      selectedGroup.select(group.id);
      state = AsyncData(next);
      return SwitchGroupResult.switched;
    } catch (error) {
      return isOfflineFailure(error)
          ? SwitchGroupResult.unavailable
          : SwitchGroupResult.failed;
    }
  }

  Future<void> showBoard() async {
    ref.read(tasksViewModeProvider.notifier).select(TasksViewMode.board);
    final current = state.value;
    final userId = _userId;
    if (current == null || userId == null) return;
    final next = await _withBoardData(userId, current);
    final latest = state.value;
    if (!ref.mounted || latest?.group?.id != next.group?.id) return;
    state = AsyncData(
      next.copyWith(
        query: latest?.query ?? next.query,
        movedTaskIds: latest?.movedTaskIds ?? next.movedTaskIds,
        tasks: _mergeTasks(latest?.tasks ?? const [], next.tasks),
      ),
    );
  }

  void showList() =>
      ref.read(tasksViewModeProvider.notifier).select(TasksViewMode.list);

  Future<MoveTaskResult> moveTask(Task task, TaskStatus status) async {
    if (task.status == status) return MoveTaskResult.moved;
    if (!ref.read(isOnlineProvider)) return MoveTaskResult.offline;
    final repository = ref.read(taskRepositoryProvider);
    final cache = _tasksCache;
    final userId = _userId;
    _replaceTask(
      task.copyWith(status: status),
      movedTaskIds: [task.id, ..._movedTaskIdsWithout(task.id)],
    );
    try {
      final updated = await repository.updateTaskStatus(task, status);
      final moved = updated.copyWith(isMine: task.isMine);
      if (userId != null) {
        unawaited(saveQuietly(() => cache.saveDetail(userId, moved)));
      }
      if (!ref.mounted) return MoveTaskResult.moved;
      if (_hasStatus(task.id, status)) _replaceTask(moved);
      _refreshTaskSummaries();
      return MoveTaskResult.moved;
    } catch (error) {
      if (ref.mounted && _hasStatus(task.id, status)) {
        _replaceTask(task, movedTaskIds: _movedTaskIdsWithout(task.id));
      }
      return isOfflineFailure(error)
          ? MoveTaskResult.offline
          : MoveTaskResult.failed;
    }
  }

  void _replaceTask(Task task, {List<String>? movedTaskIds}) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        tasks: [
          for (final existing in current.tasks)
            existing.id == task.id ? task : existing,
        ],
        movedTaskIds: movedTaskIds ?? current.movedTaskIds,
      ),
    );
  }

  List<String> _movedTaskIdsWithout(String taskId) => [
    for (final id in state.value?.movedTaskIds ?? const <String>[])
      if (id != taskId) id,
  ];

  bool _hasStatus(String taskId, TaskStatus status) =>
      state.value?.tasks.any(
        (task) => task.id == taskId && task.status == status,
      ) ??
      false;

  void _refreshTaskSummaries() {
    ref.invalidate(tasksOverviewProvider);
    ref.invalidate(calendarViewModelProvider);
    ref.invalidate(homeViewModelProvider);
    ref.read(nextTaskViewModelProvider.notifier).refresh();
  }

  Future<TasksState> _withBoardData(String userId, TasksState state) async {
    final group = state.group;
    if (group == null ||
        ref.read(tasksViewModeProvider) != TasksViewMode.board) {
      return state;
    }
    final completed = await _loadCompleted(userId, group);
    return state.copyWith(
      tasks: _mergeTasks(state.tasks, completed ?? const []),
      completedUnavailable: completed == null,
    );
  }

  List<Task> _mergeTasks(List<Task> open, List<Task> completed) => [
    for (final task in open)
      if (task.status != TaskStatus.done) task,
    ...completed.where((task) => task.status == TaskStatus.done),
  ];

  Future<List<Task>?> _loadCompleted(String userId, TaskGroup group) async {
    final cache = _tasksCache;
    try {
      final completed = await networkFirst(
        isOnline: ref.read(isOnlineProvider),
        fetch: () =>
            ref.read(taskRepositoryProvider).getGroupCompletedTasks(group),
        save: (tasks) => Future.wait([
          for (final task in tasks) cache.saveDetail(userId, task),
        ]),
        fallback: () => cache.findDoneForGroup(userId, group.id),
      );
      return completed.value;
    } on Exception catch (error, stackTrace) {
      debugPrint('Completed tasks unavailable: $error\n$stackTrace');
      return null;
    }
  }

  Future<void> createGroup(String name) async {
    await ref.read(groupRepositoryProvider).createGroup(name);
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }
}
