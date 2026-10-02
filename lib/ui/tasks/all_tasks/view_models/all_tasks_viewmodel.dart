import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';
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
  Future<AllTasksState> build() {
    return _load(ref.watch(taskRepositoryProvider), TaskFilter.urgent);
  }

  Future<AllTasksState> _load(
    TaskRepository repository,
    TaskFilter filter,
  ) async {
    final tasks = switch (filter) {
      TaskFilter.urgent => await repository.getAllTasks(priority: true),
      TaskFilter.dueSoon => await repository.getAllTasks(
        mine: true,
        dueWithinDays: 7,
      ),
      TaskFilter.assignedToMe => await repository.getAllTasks(mine: true),
    };
    return AllTasksState(tasks: tasks, filter: filter);
  }

  Future<void> updateFilter(TaskFilter filter) async {
    final current = state.value;
    if (current == null || current.filter == filter) return;
    final repository = ref.read(taskRepositoryProvider);
    state = AsyncData(AllTasksState(tasks: current.tasks, filter: filter));
    final result = await AsyncValue.guard(() => _load(repository, filter));
    if (!ref.mounted) return;
    state = result;
  }
}
