import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

class TasksState {
  const TasksState({
    required this.group,
    required this.groups,
    required this.tasks,
    required this.query,
  });

  final TaskGroup? group;
  final List<TaskGroup> groups;
  final List<Task> tasks;
  final String query;

  String get groupName => group?.name ?? 'No group';

  List<Task> get myTasks =>
      tasks.where((task) => task.isMine && _matchesQuery(task)).toList();

  List<Task> get groupTasks =>
      tasks.where((task) => !task.isMine && _matchesQuery(task)).toList();

  bool _matchesQuery(Task task) {
    if (query.isEmpty) return true;
    return task.title.toLowerCase().contains(query.toLowerCase());
  }

  TasksState copyWith({
    String? query,
    TaskGroup? group,
    List<TaskGroup>? groups,
    List<Task>? tasks,
  }) {
    return TasksState(
      group: group ?? this.group,
      groups: groups ?? this.groups,
      tasks: tasks ?? this.tasks,
      query: query ?? this.query,
    );
  }
}

class TasksViewModel extends AsyncNotifier<TasksState> {
  @override
  Future<TasksState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final groups = await repository.getTaskGroups();
    final group = groups.isEmpty ? null : groups.first;
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
    final tasks = await ref.read(taskRepositoryProvider).getGroupTasks(group);
    state = AsyncData(current.copyWith(group: group, tasks: tasks));
  }

  Future<void> createGroup(String name) async {
    await ref.read(taskRepositoryProvider).addGroup(name);
    ref.invalidateSelf();
  }
}
