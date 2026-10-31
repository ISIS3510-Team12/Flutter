import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_tasks.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

part 'tasks_cache_dao.g.dart';

@DriftAccessor(tables: [CachedTasks, CachedGroupLoads])
class TasksCacheDao extends DatabaseAccessor<AppDatabase>
    with _$TasksCacheDaoMixin {
  TasksCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForUser(String userId, List<Task> tasks) {
    return batch((batch) {
      batch.deleteWhere(
        cachedTasks,
        (t) => t.userId.equals(userId) & t.isMine.equals(true),
      );
      batch.insertAllOnConflictUpdate(cachedTasks, [
        for (final task in tasks) _toCompanion(userId, task),
      ]);
    });
  }

  Future<void> replaceForGroup(String userId, int groupId, List<Task> tasks) {
    return batch((batch) {
      batch.deleteWhere(
        cachedTasks,
        (t) => t.userId.equals(userId) & t.groupId.equals(groupId),
      );
      batch.insertAllOnConflictUpdate(cachedTasks, [
        for (final task in tasks)
          if (task.groupId == groupId) _toCompanion(userId, task),
      ]);
      batch.insert(
        cachedGroupLoads,
        CachedGroupLoadsCompanion.insert(
          userId: userId,
          groupId: groupId,
          loadedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> upsert(String userId, Task task) {
    return into(cachedTasks).insertOnConflictUpdate(_toCompanion(userId, task));
  }

  Future<void> saveDetail(String userId, Task task) {
    return upsert(
      userId,
      task.copyWith(
        isMine: task.ownerId == userId || task.assigneeIds.contains(userId),
      ),
    );
  }

  Future<Set<int>> loadedGroupIds(String userId) async {
    final query = select(cachedGroupLoads)
      ..where((l) => l.userId.equals(userId));
    final rows = await query.get();
    return {for (final row in rows) row.groupId};
  }

  Stream<List<Task>> watchPendingDueBetween(
    String userId, {
    required int startMs,
    required int endMs,
  }) {
    final query = select(cachedTasks)
      ..where(
        (t) =>
            t.userId.equals(userId) &
            t.isMine.equals(true) &
            t.status.equalsValue(TaskStatus.done).not() &
            t.deadlineUtcMs.isBiggerOrEqualValue(startMs) &
            t.deadlineUtcMs.isSmallerThanValue(endMs),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.deadlineUtcMs)]);
    return query.watch().map((rows) => rows.map(_toTask).toList());
  }

  Stream<List<Task>> watchForGroup(String userId, int groupId) {
    final query = select(cachedTasks)
      ..where((t) => t.userId.equals(userId) & t.groupId.equals(groupId))
      ..orderBy([(t) => OrderingTerm.asc(t.deadlineUtcMs)]);
    return query.watch().map((rows) => rows.map(_toTask).toList());
  }

  Future<List<Task>?> findPendingForGroup(String userId, int groupId) async {
    final loaded = await loadedGroupIds(userId);
    if (!loaded.contains(groupId)) return null;
    final tasks = await watchForGroup(userId, groupId).first;
    return [
      for (final task in tasks)
        if (task.status != TaskStatus.done) task,
    ];
  }

  Future<Task?> findTask(String userId, String id) async {
    final query = select(cachedTasks)
      ..where((t) => t.userId.equals(userId) & t.id.equals(id));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toTask(row);
  }

  Stream<int> watchUrgentCount(String userId) {
    final count = countAll();
    final query = selectOnly(cachedTasks)
      ..addColumns([count])
      ..where(
        cachedTasks.userId.equals(userId) &
            cachedTasks.isMine.equals(true) &
            cachedTasks.status.equalsValue(TaskStatus.done).not() &
            cachedTasks.isPriority.equals(true),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<List<Task>> findAll(String userId) async {
    final query = select(cachedTasks)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => OrderingTerm.asc(t.deadlineUtcMs)]);
    final rows = await query.get();
    return rows.map(_toTask).toList();
  }

  Future<List<Task>> findMine(String userId) async {
    final query = select(cachedTasks)
      ..where((t) => t.userId.equals(userId) & t.isMine.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.deadlineUtcMs)]);
    final rows = await query.get();
    return rows.map(_toTask).toList();
  }

  Future<bool> refresh(
    String userId,
    Future<List<Task>> Function() fetch,
  ) async {
    try {
      final tasks = await fetch();
      await replaceForUser(userId, tasks);
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Tasks cache refresh failed: $error\n$stackTrace');
      return false;
    }
  }

  CachedTasksCompanion _toCompanion(String userId, Task task) {
    return CachedTasksCompanion.insert(
      userId: userId,
      id: task.id,
      title: task.title,
      groupName: task.groupName,
      groupId: Value(task.groupId),
      description: task.description,
      assignees: task.assignees,
      type: task.type,
      status: task.status,
      deadlineUtcMs: task.deadline.toUtc().millisecondsSinceEpoch,
      isMine: task.isMine,
      isPriority: task.isPriority,
      needsHelp: task.needsHelp,
      ownerId: Value(task.ownerId),
      assigneeIds: task.assigneeIds,
      projectId: Value(task.projectId),
      projectName: Value(task.projectName),
      relatedTaskIds: task.relatedTaskIds,
      relatedTasks: task.relatedTasks,
      hasPhoto: Value(task.hasPhoto),
    );
  }

  Task _toTask(CachedTaskRow row) {
    return Task(
      id: row.id,
      title: row.title,
      description: row.description,
      type: row.type,
      status: row.status,
      groupName: row.groupName,
      groupId: row.groupId,
      assignees: row.assignees,
      deadline: DateTime.fromMillisecondsSinceEpoch(
        row.deadlineUtcMs,
        isUtc: true,
      ).toLocal(),
      isMine: row.isMine,
      isPriority: row.isPriority,
      needsHelp: row.needsHelp,
      ownerId: row.ownerId,
      assigneeIds: row.assigneeIds,
      projectId: row.projectId,
      projectName: row.projectName,
      relatedTaskIds: row.relatedTaskIds,
      relatedTasks: row.relatedTasks,
      hasPhoto: row.hasPhoto,
    );
  }
}
