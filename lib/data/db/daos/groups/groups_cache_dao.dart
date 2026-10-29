import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_groups.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

part 'groups_cache_dao.g.dart';

@DriftAccessor(tables: [CachedGroups])
class GroupsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$GroupsCacheDaoMixin {
  GroupsCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForUser(String userId, List<TaskGroup> groups) {
    return batch((batch) {
      batch.deleteWhere(cachedGroups, (g) => g.userId.equals(userId));
      batch.insertAll(cachedGroups, [
        for (final group in groups) _toCompanion(userId, group),
      ]);
    });
  }

  Future<void> save(String userId, TaskGroup group) {
    return into(cachedGroups).insertOnConflictUpdate(
      _toCompanion(userId, group),
    );
  }

  Stream<List<TaskGroup>> watchAll(String userId) {
    final query = select(cachedGroups)
      ..where((g) => g.userId.equals(userId))
      ..orderBy([(g) => OrderingTerm.asc(g.name)]);
    return query.watch().map((rows) => rows.map(_toGroup).toList());
  }

  Stream<TaskGroup?> watchGroup(String userId, int groupId) {
    final query = select(cachedGroups)
      ..where((g) => g.userId.equals(userId) & g.id.equals(groupId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toGroup(row),
    );
  }

  CachedGroupsCompanion _toCompanion(String userId, TaskGroup group) {
    return CachedGroupsCompanion.insert(
      userId: userId,
      id: group.id,
      name: group.name,
      description: group.description,
      pendingCount: group.pendingCount,
      members: group.members,
    );
  }

  Future<bool> refresh(
    String userId,
    Future<List<TaskGroup>> Function() fetch,
  ) async {
    try {
      final groups = await fetch();
      await replaceForUser(userId, groups);
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Groups cache refresh failed: $error\n$stackTrace');
      return false;
    }
  }

  TaskGroup _toGroup(CachedGroupRow row) {
    return TaskGroup(
      id: row.id,
      name: row.name,
      description: row.description,
      pendingCount: row.pendingCount,
      members: row.members,
    );
  }
}
