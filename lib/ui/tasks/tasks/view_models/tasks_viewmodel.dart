import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TasksState {
  const TasksState({
    required this.groupName,
    required this.groups,
    required this.tasks,
    required this.query,
  });

  final String groupName;
  final List<String> groups;
  final List<Task> tasks;
  final String query;

  List<Task> get myTasks => tasks
      .where(
        (task) =>
            task.groupName == groupName && task.isMine && _matchesQuery(task),
      )
      .toList();

  List<Task> get groupTasks => tasks
      .where(
        (task) =>
            task.groupName == groupName && !task.isMine && _matchesQuery(task),
      )
      .toList();

  int pendingCountFor(String group) => tasks
      .where(
        (task) => task.groupName == group && task.status != TaskStatus.done,
      )
      .length;

  bool _matchesQuery(Task task) {
    if (query.isEmpty) return true;
    return task.title.toLowerCase().contains(query.toLowerCase());
  }

  TasksState copyWith({
    String? query,
    String? groupName,
    List<String>? groups,
  }) {
    return TasksState(
      groupName: groupName ?? this.groupName,
      groups: groups ?? this.groups,
      tasks: tasks,
      query: query ?? this.query,
    );
  }
}

class TasksViewModel extends AsyncNotifier<TasksState> {
  @override
  Future<TasksState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final groupName = await repository.getCurrentGroupName();
    final groups = await repository.getGroups();
    final tasks = await repository.getTasks();
    return TasksState(
      groupName: groupName,
      groups: groups,
      tasks: tasks,
      query: '',
    );
  }

  void updateQuery(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: value));
  }

  void switchGroup(String name) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(groupName: name));
  }

  Future<void> createGroup(String name) async {
    final current = state.value;
    if (current == null) return;
    await ref.read(taskRepositoryProvider).addGroup(name);
    state = AsyncData(current.copyWith(groups: [...current.groups, name]));
  }
}
