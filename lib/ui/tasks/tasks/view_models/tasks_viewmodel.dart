import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/groups/group_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/selected_task_group_provider.dart';
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
  }) = _TasksState;

  String get groupName => group?.name ?? 'No group';

  List<Task> get myTasks =>
      _sorted(tasks.where((task) => task.isMine && _matchesQuery(task)));

  List<Task> get groupTasks =>
      _sorted(tasks.where((task) => !task.isMine && _matchesQuery(task)));

  List<Task> _sorted(Iterable<Task> source) {
    return source.toList()..sort((a, b) {
      final byDeadline = a.deadline.compareTo(b.deadline);
      if (byDeadline != 0) return byDeadline;
      if (a.isPriority != b.isPriority) return a.isPriority ? -1 : 1;
      final idA = int.tryParse(a.id) ?? 0;
      final idB = int.tryParse(b.id) ?? 0;
      return idA.compareTo(idB);
    });
  }

  bool _matchesQuery(Task task) {
    if (query.isEmpty) return true;
    return task.title.toLowerCase().contains(query.toLowerCase());
  }
}

class TasksViewModel extends AsyncNotifier<TasksState> {
  @override
  Future<TasksState> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final groups = await ref.watch(groupRepositoryProvider).getGroups();
    final group = selectedGroup.resolve(groups);
    final tasks = group == null
        ? <Task>[]
        : await repository.getGroupTasks(group);
    return TasksState(group: group, groups: groups, tasks: tasks, query: '');
  }

  void updateQuery(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: value));
  }

  Future<void> switchGroup(TaskGroup group) async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(taskRepositoryProvider);
    final selectedGroup = ref.read(selectedTaskGroupIdProvider.notifier);
    final result = await AsyncValue.guard(() async {
      final tasks = await repository.getGroupTasks(group);
      return current.copyWith(group: group, tasks: tasks);
    });
    if (!ref.mounted) return;
    if (result.hasValue) selectedGroup.select(group.id);
    state = result;
  }

  Future<void> createGroup(String name) async {
    await ref.read(groupRepositoryProvider).createGroup(name);
    if (!ref.mounted) return;
    ref.invalidateSelf();
  }
}
