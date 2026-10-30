import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/cache/tasks_offline_cache_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'dart:typed_data';

part 'view_task_viewmodel.freezed.dart';

@freezed
abstract class ViewTaskState with _$ViewTaskState {
  const factory ViewTaskState({
    required Task task,
    required List<Task> relatedTasks,
    required bool reminderEnabled,
    Uint8List? photo,
    @Default(false) bool photoUnavailable,
    @Default(false) bool fromCache,
  }) = _ViewTaskState;
}

enum TaskActionResult { done, offline, failed }

class ViewTaskViewModel extends AsyncNotifier<ViewTaskState> {
  ViewTaskViewModel(this.taskId);

  final String taskId;

  @override
  Future<ViewTaskState> build() async {
    final repository = ref.watch(taskRepositoryProvider);
    final Task task;
    try {
      task = await repository.getTask(taskId);
    } catch (error) {
      if (!isOfflineFailure(error)) rethrow;
      final cached = await _cachedTask();
      if (cached == null) rethrow;
      return ViewTaskState(
        task: cached,
        relatedTasks: const [],
        reminderEnabled: true,
        fromCache: true,
      );
    }
    Uint8List? photo;
    var photoUnavailable = false;
    if (task.hasPhoto) {
      try {
        photo = await repository.getTaskPhoto(taskId);
      } catch (_) {
        photoUnavailable = true;
      }
    }
    return ViewTaskState(
      task: task,
      relatedTasks: task.relatedTasks,
      reminderEnabled: true,
      photo: photo,
      photoUnavailable: photoUnavailable,
    );
  }

  Future<Task?> _cachedTask() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return null;
    return ref.read(tasksOfflineCacheProvider).task(user.userId, taskId);
  }

  void toggleReminder(bool value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(reminderEnabled: value));
  }

  Future<TaskActionResult> markComplete() => _changeStatus(TaskStatus.done);

  Future<TaskActionResult> markStarted() =>
      _changeStatus(TaskStatus.inProgress);

  Future<TaskActionResult> _changeStatus(TaskStatus status) {
    return _applyUpdate(
      (repository, task) => repository.updateTaskStatus(task, status),
    );
  }

  Future<TaskActionResult> toggleNeedsHelp() {
    return _applyUpdate(
      (repository, task) =>
          repository.updateTask(task.copyWith(needsHelp: !task.needsHelp)),
    );
  }

  Future<TaskActionResult> updateDeadline(DateTime deadline) {
    return _applyUpdate(
      (repository, task) =>
          repository.updateTask(task.copyWith(deadline: deadline)),
    );
  }

  bool get _blocked => !ref.read(isOnlineProvider);

  Future<TaskActionResult> _applyUpdate(
    Future<Task> Function(TaskRepository repository, Task task) operation,
  ) async {
    final current = state.value;
    if (current == null) return TaskActionResult.failed;
    if (_blocked) return TaskActionResult.offline;
    final repository = ref.read(taskRepositoryProvider);
    try {
      final updated = await operation(repository, current.task);
      if (!ref.mounted) return TaskActionResult.done;
      state = AsyncData(current.copyWith(task: updated));
      _invalidateRelated();
      return TaskActionResult.done;
    } catch (error) {
      return isOfflineFailure(error)
          ? TaskActionResult.offline
          : TaskActionResult.failed;
    }
  }

  Future<TaskActionResult> deleteTask() async {
    if (_blocked) return TaskActionResult.offline;
    final repository = ref.read(taskRepositoryProvider);
    try {
      await repository.deleteTask(taskId);
    } catch (error) {
      return isOfflineFailure(error)
          ? TaskActionResult.offline
          : TaskActionResult.failed;
    }
    if (ref.mounted) _invalidateRelated();
    return TaskActionResult.done;
  }

  void _invalidateRelated() {
    ref.invalidate(tasksViewModelProvider);
    ref.invalidate(tasksOverviewProvider);
    ref.invalidate(calendarViewModelProvider);
    ref.invalidate(homeViewModelProvider);
  }
}
