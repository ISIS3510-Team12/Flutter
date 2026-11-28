import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_photo_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_photos.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';

part 'project_photos_cache_dao.g.dart';

@DriftAccessor(tables: [CachedProjectPhotos, CachedProjectPhotoLoads])
class ProjectPhotosCacheDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectPhotosCacheDaoMixin {
  ProjectPhotosCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForProject(
    String userId,
    int projectId,
    List<ProjectPhoto> photos,
  ) {
    return transaction(() async {
      await (delete(cachedProjectPhotos)..where(
            (p) => p.userId.equals(userId) & p.projectId.equals(projectId),
          ))
          .go();
      await batch((batch) {
        batch.insertAllOnConflictUpdate(cachedProjectPhotos, [
          for (final photo in photos) _toCompanion(userId, photo),
        ]);
      });
      await into(cachedProjectPhotoLoads).insertOnConflictUpdate(
        CachedProjectPhotoLoadsCompanion.insert(
          userId: userId,
          projectId: projectId,
          loadedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<List<ProjectPhoto>?> findForProject(
    String userId,
    int projectId,
  ) async {
    final load =
        await (select(cachedProjectPhotoLoads)..where(
              (l) => l.userId.equals(userId) & l.projectId.equals(projectId),
            ))
            .getSingleOrNull();
    if (load == null) return null;

    final query = select(cachedProjectPhotos)
      ..where((p) => p.userId.equals(userId) & p.projectId.equals(projectId))
      ..orderBy([
        (p) => OrderingTerm.desc(p.createdAtUtcMs),
        (p) => OrderingTerm.desc(p.id),
      ]);
    final rows = await query.get();
    return rows.map(_toPhoto).toList();
  }

  Future<void> remove(String userId, int photoId) {
    return (delete(
      cachedProjectPhotos,
    )..where((p) => p.userId.equals(userId) & p.id.equals(photoId))).go();
  }

  CachedProjectPhotosCompanion _toCompanion(String userId, ProjectPhoto photo) {
    return CachedProjectPhotosCompanion.insert(
      userId: userId,
      id: photo.id,
      projectId: photo.projectId,
      uploaderId: photo.uploaderId,
      uploaderName: photo.uploaderName,
      createdAtUtcMs: photo.createdAt.toUtc().millisecondsSinceEpoch,
      caption: Value(photo.caption),
    );
  }

  ProjectPhoto _toPhoto(CachedProjectPhotoRow row) {
    return ProjectPhoto(
      id: row.id,
      projectId: row.projectId,
      uploaderId: row.uploaderId,
      uploaderName: row.uploaderName,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        row.createdAtUtcMs,
        isUtc: true,
      ).toLocal(),
      caption: row.caption,
    );
  }
}
