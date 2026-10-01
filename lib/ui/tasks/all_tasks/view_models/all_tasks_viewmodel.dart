import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

enum TaskFilter { urgent, dueSoon, assignedToMe }

class AllTasksState {
  const AllTasksState({required this.tasks, required this.filter});

  final List<Task> tasks;
  final TaskFilter filter;

  List<Task> get filteredTasks => tasks;
}

class AllTasksViewModel extends AsyncNotifier<AllTasksState> {
  @override
  Future<AllTasksState> build() => _load(TaskFilter.urgent);

  Future<AllTasksState> _load(TaskFilter filter) async {
    final repository = ref.read(taskRepositoryProvider);
    final tasks = switch (filter) {
      TaskFilter.urgent => await repository.getAllTasks(priority: true),
      TaskFilter.dueSoon => await repository.getAllTasks(dueWithinDays: 1),
      TaskFilter.assignedToMe => await repository.getAllTasks(mine: true),
    };
    return AllTasksState(tasks: tasks, filter: filter);
  }

  Future<void> updateFilter(TaskFilter filter) async {
    final current = state.value;
    if (current == null || current.filter == filter) return;
    state = AsyncData(AllTasksState(tasks: current.tasks, filter: filter));
    state = await AsyncValue.guard(() => _load(filter));
  }
}
