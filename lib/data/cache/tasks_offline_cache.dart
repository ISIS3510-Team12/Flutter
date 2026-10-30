import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';

typedef CacheRead<T> = ({T value, bool fromCache});

Future<CacheRead<T>> networkFirst<T>({
  required bool isOnline,
  required Future<T> Function() fetch,
  required Future<void> Function(T value) save,
  required Future<T?> Function() fallback,
}) async {
  Object failure = const NetworkUnavailableException();
  var trace = StackTrace.current;
  if (isOnline) {
    try {
      final value = await fetch();
      await save(value);
      return (value: value, fromCache: false);
    } catch (error, stackTrace) {
      if (!isOfflineFailure(error)) rethrow;
      failure = error;
      trace = stackTrace;
    }
  }
  final cached = await fallback();
  if (cached == null) Error.throwWithStackTrace(failure, trace);
  return (value: cached, fromCache: true);
}

class TasksOfflineCache {
  TasksOfflineCache({
    required GroupsCacheDao groups,
    required ProjectsCacheDao projects,
    required TasksCacheDao tasks,
  }) : _groups = groups,
       _projects = projects,
       _tasks = tasks;

  final GroupsCacheDao _groups;
  final ProjectsCacheDao _projects;
  final TasksCacheDao _tasks;

  Future<void> saveGroups(String userId, List<TaskGroup> groups) =>
      _write(() => _groups.replaceForUser(userId, groups));

  Future<void> saveProjects(
    String userId,
    int groupId,
    List<Project> projects,
  ) => _write(() => _projects.replaceForGroup(userId, groupId, projects));

  Future<void> saveGroupTasks(String userId, int groupId, List<Task> tasks) =>
      _write(
        () => _tasks.replaceForGroup(userId, groupId, [
          for (final task in tasks)
            if (task.groupId == groupId) task,
        ]),
      );

  Future<void> saveTask(String userId, Task task) => _write(
    () => _tasks.upsert(
      userId,
      task.copyWith(
        isMine: task.ownerId == userId || task.assigneeIds.contains(userId),
      ),
    ),
  );

  Future<Set<int>> loadedGroupIds(String userId) =>
      _tasks.loadedGroupIds(userId);

  Future<List<TaskGroup>?> groups(String userId) async {
    final groups = await _groups.watchAll(userId).first;
    return groups.isEmpty ? null : groups;
  }

  Future<List<Project>> projects(String userId, int groupId) =>
      _projects.watchForGroup(userId, groupId).first;

  Future<List<Task>?> groupTasks(String userId, TaskGroup group) async {
    final loaded = await _tasks.loadedGroupIds(userId);
    if (!loaded.contains(group.id)) return null;
    final tasks = await _tasks.watchForGroup(userId, group.id).first;
    return [
      for (final task in tasks)
        if (task.status != TaskStatus.done) task,
    ];
  }

  Future<Task?> task(String userId, String taskId) =>
      _tasks.findTask(userId, taskId);

  Future<void> _write(Future<void> Function() write) async {
    try {
      await write();
    } catch (error, stackTrace) {
      debugPrint('Offline cache write failed: $error\n$stackTrace');
    }
  }
}
