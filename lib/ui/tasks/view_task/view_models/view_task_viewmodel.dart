import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

class ViewTaskState {
  const ViewTaskState({
    required this.task,
    required this.relatedTasks,
    required this.reminderEnabled,
    this.timeSlotLabel,
  });

  final Task task;
  final List<Task> relatedTasks;
  final bool reminderEnabled;
  final String? timeSlotLabel;

  ViewTaskState copyWith({
    Task? task,
    bool? reminderEnabled,
    String? timeSlotLabel,
  }) {
    return ViewTaskState(
      task: task ?? this.task,
      relatedTasks: relatedTasks,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      timeSlotLabel: timeSlotLabel ?? this.timeSlotLabel,
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
        .where((other) => task.relatedTaskIds.contains(other.id))
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

  Future<void> markComplete() => _changeStatus(TaskStatus.done);

  Future<void> markStarted() => _changeStatus(TaskStatus.inProgress);

  Future<void> _changeStatus(TaskStatus status) async {
    final current = state.value;
    if (current == null) return;
    final updated = await ref
        .read(taskRepositoryProvider)
        .updateTaskStatus(current.task, status);
    state = AsyncData(current.copyWith(task: updated));
    ref.invalidate(tasksViewModelProvider);
  }

  Future<void> toggleNeedsHelp() async {
    final current = state.value;
    if (current == null) return;
    final edited = current.task.copyWith(needsHelp: !current.task.needsHelp);
    final updated = await ref.read(taskRepositoryProvider).updateTask(edited);
    state = AsyncData(current.copyWith(task: updated));
    ref.invalidate(tasksViewModelProvider);
  }

  Future<void> deleteTask() async {
    await ref.read(taskRepositoryProvider).deleteTask(taskId);
    ref.invalidate(tasksViewModelProvider);
  }

  void setTimeSlot(String label) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(timeSlotLabel: label));
  }
}
