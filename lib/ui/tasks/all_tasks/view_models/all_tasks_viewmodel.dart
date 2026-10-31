import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

part 'all_tasks_viewmodel.freezed.dart';

enum TaskFilter { urgent, dueSoon, assignedToMe }

@freezed
abstract class AllTasksState with _$AllTasksState {
  const AllTasksState._();

  const factory AllTasksState({
    required List<Task> tasks,
    required TaskFilter filter,
    @Default(false) bool fromCache,
  }) = _AllTasksState;

  List<Task> get filteredTasks => tasks;
}

class AllTasksViewModel extends AsyncNotifier<AllTasksState> {
  @override
  Future<AllTasksState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) throw StateError('User is not logged in');
    ref.watch(isOnlineProvider);
    return _load(user.userId, state.value?.filter ?? TaskFilter.urgent);
  }

  Future<AllTasksState> _load(String userId, TaskFilter filter) async {
    final repository = ref.read(taskRepositoryProvider);
    final cache = ref.read(tasksCacheDaoProvider);
    final now = ref.read(clockProvider).now();
    final read = await networkFirst(
      isOnline: ref.read(isOnlineProvider),
      fetch: () => _fetch(repository, filter),
      save: (tasks) => filter == TaskFilter.assignedToMe
          ? cache.replaceForUser(userId, tasks)
          : Future.value(),
      fallback: () => _fromCache(cache, userId, filter, now),
    );
    return AllTasksState(
      tasks: read.value,
      filter: filter,
      fromCache: read.fromCache,
    );
  }

  Future<List<Task>> _fetch(TaskRepository repository, TaskFilter filter) {
    return switch (filter) {
      TaskFilter.urgent => repository.getAllTasks(priority: true),
      TaskFilter.dueSoon => repository.getAllTasks(
        mine: true,
        dueWithinDays: 7,
      ),
      TaskFilter.assignedToMe => repository.getAllTasks(mine: true),
    };
  }

  Future<List<Task>> _fromCache(
    TasksCacheDao cache,
    String userId,
    TaskFilter filter,
    DateTime now,
  ) async {
    final limit = now.add(const Duration(days: 7));
    return switch (filter) {
      TaskFilter.urgent => [
        for (final task in await cache.findAll(userId))
          if (task.isPriority && task.status != TaskStatus.done) task,
      ],
      TaskFilter.dueSoon => [
        for (final task in await cache.findMine(userId))
          if (task.status != TaskStatus.done &&
              !task.deadline.isBefore(now) &&
              task.deadline.isBefore(limit))
            task,
      ],
      TaskFilter.assignedToMe => await cache.findMine(userId),
    };
  }

  Future<void> updateFilter(TaskFilter filter) async {
    final current = state.value;
    if (current == null || current.filter == filter) return;
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    state = AsyncData(
      AllTasksState(
        tasks: current.tasks,
        filter: filter,
        fromCache: current.fromCache,
      ),
    );
    final result = await AsyncValue.guard(() => _load(user.userId, filter));
    if (!ref.mounted) return;
    state = result;
  }
}
