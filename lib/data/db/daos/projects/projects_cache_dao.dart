import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_projects.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';

part 'projects_cache_dao.g.dart';

@DriftAccessor(tables: [CachedProjects])
class ProjectsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsCacheDaoMixin {
  ProjectsCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForGroup(
    String userId,
    int groupId,
    List<Project> projects,
  ) {
    return batch((batch) {
      batch.deleteWhere(
        cachedProjects,
        (p) => p.userId.equals(userId) & p.groupId.equals(groupId),
      );
      batch.insertAll(cachedProjects, [
        for (final project in projects) _toCompanion(userId, project),
      ]);
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

  Future<List<Project>> findForGroup(String userId, int groupId) =>
      watchForGroup(userId, groupId).first;

  Stream<Project?> watchProject(String userId, int projectId) {
    final query = select(cachedProjects)
      ..where((p) => p.userId.equals(userId) & p.id.equals(projectId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _toProject(row),
    );
  }

  CachedProjectsCompanion _toCompanion(String userId, Project project) {
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
