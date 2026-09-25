import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class ViewTaskState {
  const ViewTaskState({
    required this.task,
    required this.relatedTasks,
    required this.reminderEnabled,
  });

  final Task task;
  final List<Task> relatedTasks;
  final bool reminderEnabled;

  ViewTaskState copyWith({bool? reminderEnabled}) {
    return ViewTaskState(
      task: task,
      relatedTasks: relatedTasks,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }
}

class ViewTaskViewModel extends AsyncNotifier<ViewTaskState> {
  ViewTaskViewModel(this.taskId);

  final String taskId;

  @override
  Future<ViewTaskState> build() async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.getTask(taskId);
    final allTasks = await repository.getTasks();
    final relatedTasks = allTasks
        .where(
          (other) => other.id != task.id && other.groupName == task.groupName,
        )
        .toList();
    return ViewTaskState(
      task: task,
      relatedTasks: relatedTasks,
      reminderEnabled: true,
    );
  }

  void toggleReminder(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(reminderEnabled: value));
  }
}
