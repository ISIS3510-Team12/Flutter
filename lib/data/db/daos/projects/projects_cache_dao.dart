
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_projects.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_group_loads.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';

part 'projects_cache_dao.g.dart';

@DriftAccessor(
  tables: [CachedProjects, CachedProjectGroupLoads],
)
class ProjectsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsCacheDaoMixin {
  ProjectsCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForGroup(
    String userId,
    int groupId,
    List<Project> projects,
  ) {
    return transaction(() async {
      await (delete(cachedProjects)
            ..where(
              (p) => p.userId.equals(userId) & p.groupId.equals(groupId),
            ))
          .go();

      if (projects.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedProjects, [
            for (final project in projects)
              _toCompanion(userId, project),
          ]);
        });
      }

      await into(cachedProjectGroupLoads).insertOnConflictUpdate(
        CachedProjectGroupLoadsCompanion.insert(
          userId: userId,
          groupId: groupId,
          loadedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<void> save(String userId, Project project) {
    return into(cachedProjects)
        .insertOnConflictUpdate(_toCompanion(userId, project));
  }

  Stream<List<Project>> watchForGroup(String userId, int groupId) {
    final query = select(cachedProjects)
      ..where((p) => p.userId.equals(userId) & p.groupId.equals(groupId))
      ..orderBy([(p) => OrderingTerm.asc(p.deadlineUtcMs)]);

    return query.watch().map((rows) => rows.map(_toProject).toList());
  }

  Future<List<Project>?> findForGroup(
    String userId,
    int groupId,
  ) async {
    final load = await (select(cachedProjectGroupLoads)
          ..where(
            (p) => p.userId.equals(userId) & p.groupId.equals(groupId),
          ))
        .getSingleOrNull();

    if (load == null) return null;

    final query = select(cachedProjects)
      ..where((p) => p.userId.equals(userId) & p.groupId.equals(groupId))
      ..orderBy([(p) => OrderingTerm.asc(p.deadlineUtcMs)]);

    final rows = await query.get();
    return rows.map(_toProject).toList();
  }

  Future<bool> isGroupLoaded(String userId, int groupId) async {
    final load = await (select(cachedProjectGroupLoads)
          ..where(
            (p) => p.userId.equals(userId) & p.groupId.equals(groupId),
          ))
        .getSingleOrNull();

    return load != null;
  }

  Stream<Project?> watchProject(String userId, int projectId) {
    final query = select(cachedProjects)
      ..where((p) => p.userId.equals(userId) & p.id.equals(projectId));

    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toProject(row),
    );
  }

  Future<Project?> findProject(String userId, int projectId) async {
    final row = await (select(cachedProjects)
          ..where(
            (p) => p.userId.equals(userId) & p.id.equals(projectId),
          ))
        .getSingleOrNull();

    return row == null ? null : _toProject(row);
  }

  CachedProjectsCompanion _toCompanion(
    String userId,
    Project project,
  ) {
    return CachedProjectsCompanion.insert(
      userId: userId,
      id: project.id,
      groupId: project.groupId,
      name: project.name,
      description: project.description,
      deadlineUtcMs: project.deadline.toUtc().millisecondsSinceEpoch,
    );
  }

  Future<bool> refresh(
    String userId,
    int groupId,
    Future<List<Project>> Function() fetch,
  ) async {
    try {
      final projects = await fetch();
      await replaceForGroup(userId, groupId, projects);
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Projects cache refresh failed: $error\n$stackTrace');
      return false;
    }
  }

  Project _toProject(CachedProjectRow row) {
    return Project(
      id: row.id,
      groupId: row.groupId,
      name: row.name,
      description: row.description,
      deadline: DateTime.fromMillisecondsSinceEpoch(
        row.deadlineUtcMs,
        isUtc: true,
      ).toLocal(),
    );
  }
}
