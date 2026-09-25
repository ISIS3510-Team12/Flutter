import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TasksState {
  const TasksState({
    required this.groupName,
    required this.tasks,
    required this.query,
  });

  final String groupName;
  final List<Task> tasks;
  final String query;

  List<Task> get myTasks =>
      tasks.where((task) => task.isMine && _matchesQuery(task)).toList();

  List<Task> get groupTasks =>
      tasks.where((task) => !task.isMine && _matchesQuery(task)).toList();

  bool _matchesQuery(Task task) {
    if (query.isEmpty) return true;
    return task.title.toLowerCase().contains(query.toLowerCase());
  }

  TasksState copyWith({String? query}) {
    return TasksState(
      groupName: groupName,
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
    final tasks = await repository.getTasks();
    return TasksState(groupName: groupName, tasks: tasks, query: '');
  }

  void updateQuery(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(query: value));
  }
}
