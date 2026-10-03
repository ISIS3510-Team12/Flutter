import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

class ViewTaskState {
  const ViewTaskState({
    required this.task,
    required this.relatedTasks,
    required this.reminderEnabled,
    this.photo,
  });

  final Task task;
  final List<Task> relatedTasks;
  final bool reminderEnabled;
  final Uint8List? photo;

  ViewTaskState copyWith({Task? task, bool? reminderEnabled}) {
    return ViewTaskState(
      task: task ?? this.task,
      relatedTasks: relatedTasks,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      photo: photo,
    );
  }
}

class ViewTaskViewModel extends AsyncNotifier<ViewTaskState> {
  ViewTaskViewModel(this.taskId);

  final String taskId;

  @override
  Future<ViewTaskState> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    final task = await repository.getTask(taskId);
    final photo = task.hasPhoto ? await repository.getTaskPhoto(taskId) : null;
    return ViewTaskState(
      task: task,
      relatedTasks: task.relatedTasks,
      reminderEnabled: true,
      photo: photo,
    );
  }

  void toggleReminder(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(reminderEnabled: value));
  }

  Future<void> markComplete() => _changeStatus(TaskStatus.done);

  Future<void> markStarted() => _changeStatus(TaskStatus.inProgress);

  Future<void> _changeStatus(TaskStatus status) {
    return _applyUpdate(
      (repository, task) => repository.updateTaskStatus(task, status),
    );
  }

  Future<void> toggleNeedsHelp() {
    return _applyUpdate(
      (repository, task) =>
          repository.updateTask(task.copyWith(needsHelp: !task.needsHelp)),
    );
  }

  Future<void> updateDeadline(DateTime deadline) {
    return _applyUpdate(
      (repository, task) =>
          repository.updateTask(task.copyWith(deadline: deadline)),
    );
  }

  Future<void> _applyUpdate(
    Future<Task> Function(TaskRepository repository, Task task) operation,
  ) async {
    final current = state.value;
    if (current == null) return;
    final repository = ref.read(taskRepositoryProvider);
    final result = await AsyncValue.guard(() async {
      final updated = await operation(repository, current.task);
      return current.copyWith(task: updated);
    });
    if (!ref.mounted) return;
    state = result;
    if (result.hasError) return;
    ref.invalidate(tasksViewModelProvider);
    ref.invalidate(tasksOverviewProvider);
    ref.invalidate(calendarViewModelProvider);
    ref.invalidate(homeViewModelProvider);
  }

  Future<void> deleteTask() async {
    final repository = ref.read(taskRepositoryProvider);
    await repository.deleteTask(taskId);
    if (!ref.mounted) return;
    ref.invalidate(tasksViewModelProvider);
    ref.invalidate(tasksOverviewProvider);
    ref.invalidate(calendarViewModelProvider);
    ref.invalidate(homeViewModelProvider);
  }
}
