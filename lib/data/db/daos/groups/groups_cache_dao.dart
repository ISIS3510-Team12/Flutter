import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_list_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_groups.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';

part 'groups_cache_dao.g.dart';

@DriftAccessor(
  tables: [
    CachedGroups,
    CachedGroupLoads,
    CachedGroupListLoads,
  ],
)
class GroupsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$GroupsCacheDaoMixin {
  GroupsCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForUser(
    String userId,
    List<TaskGroup> groups,
  ) async {
    await transaction(() async {
      await (delete(cachedGroups)
            ..where((g) => g.userId.equals(userId)))
          .go();

      await batch((batch) {
        batch.insertAll(cachedGroups, [
          for (final (index, group) in groups.indexed)
            _toCompanion(userId, group, position: index),
        ]);

        batch.deleteWhere(
          cachedGroupLoads,
          (l) =>
              l.userId.equals(userId) &
              l.groupId.isNotIn([
                for (final group in groups) group.id,
              ]),
        );
      });

      await into(cachedGroupListLoads).insertOnConflictUpdate(
        CachedGroupListLoadsCompanion.insert(
          userId: userId,
          loadedAtUtcMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<void> save(String userId, TaskGroup group) {
    return into(cachedGroups)
        .insertOnConflictUpdate(_toCompanion(userId, group));
  }

  Stream<List<TaskGroup>> watchAll(String userId) {
    final query = select(cachedGroups)
      ..where((g) => g.userId.equals(userId))
      ..orderBy([
        (g) => OrderingTerm.asc(g.position),
        (g) => OrderingTerm.asc(g.name),
      ]);

    return query.watch().map(
      (rows) => rows.map(_toGroup).toList(),
    );
  }

  Future<List<TaskGroup>?> findAll(String userId) async {
    final load = await (select(cachedGroupListLoads)
          ..where((l) => l.userId.equals(userId)))
        .getSingleOrNull();

    if (load == null) {
      return null;
    }

    return watchAll(userId).first;
  }

  Stream<TaskGroup?> watchGroup(String userId, int groupId) {
    final query = select(cachedGroups)
      ..where(
        (g) => g.userId.equals(userId) & g.id.equals(groupId),
      );

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toGroup(row),
    );
  }

  CachedGroupsCompanion _toCompanion(
    String userId,
    TaskGroup group, {
    int? position,
  }) {
    return CachedGroupsCompanion.insert(
      userId: userId,
      id: group.id,
      name: group.name,
      description: group.description,
      pendingCount: group.pendingCount,
      members: group.members,
      position: position == null
          ? const Value.absent()
          : Value(position),
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