import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

enum TaskFilter { urgent, dueSoon, assignedToMe }

class AllTasksState {
  const AllTasksState({required this.tasks, required this.filter});

  final List<Task> tasks;
  final TaskFilter filter;

  List<Task> get filteredTasks {
    switch (filter) {
      case TaskFilter.urgent:
        return tasks.where((task) => task.isPriority).toList();
      case TaskFilter.dueSoon:
        return tasks.where(_isDueSoon).toList();
      case TaskFilter.assignedToMe:
        return tasks.where((task) => task.isMine).toList();
    }
  }

  bool _isDueSoon(Task task) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      task.deadline.year,
      task.deadline.month,
      task.deadline.day,
    );
    final daysAway = day.difference(today).inDays;
    return daysAway >= 0 && daysAway <= 1;
  }

  AllTasksState copyWith({TaskFilter? filter}) {
    return AllTasksState(tasks: tasks, filter: filter ?? this.filter);
  }
}

class AllTasksViewModel extends AsyncNotifier<AllTasksState> {
  @override
  Future<AllTasksState> build() async {
    final tasks = await ref.read(taskRepositoryProvider).getTasks();
    return AllTasksState(tasks: tasks, filter: TaskFilter.urgent);
  }

  void updateFilter(TaskFilter filter) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(filter: filter));
  }
}
