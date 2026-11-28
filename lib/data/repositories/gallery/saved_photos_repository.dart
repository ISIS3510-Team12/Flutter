import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:team12_flutter_juggle/data/local/gallery/gallery_database.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/project_photo.dart';
import 'package:team12_flutter_juggle/domain/models/gallery/saved_photo.dart';

class SavedPhotosRepository {
  SavedPhotosRepository(
    this._db, {
    Future<Directory> Function()? documentsDirectory,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final GalleryDatabase _db;
  final Future<Directory> Function() _documentsDirectory;

  Stream<List<SavedPhoto>> watchForProject(String userId, int projectId) {
    final query =
        _db.select(_db.savedPhotos).join([
            innerJoin(
              _db.savedProjects,
              _db.savedProjects.userId.equalsExp(_db.savedPhotos.userId) &
                  _db.savedProjects.projectId.equalsExp(
                    _db.savedPhotos.projectId,
                  ),
            ),
          ])
          ..where(
            _db.savedPhotos.userId.equals(userId) &
                _db.savedPhotos.projectId.equals(projectId),
          )
          ..orderBy([
            OrderingTerm.desc(_db.savedPhotos.createdAtUtcMs),
            OrderingTerm.desc(_db.savedPhotos.photoId),
          ]);

    return query.watch().asyncMap((rows) async {
      final directory = await _directory(userId);
      return [
        for (final row in rows)
          _toSavedPhoto(
            row.readTable(_db.savedPhotos),
            row.readTable(_db.savedProjects).name,
            directory,
          ),
      ];
    });
  }

  Future<void> save({
    required String userId,
    required String projectName,
    required ProjectPhoto photo,
    required File source,
  }) async {
    final directory = await _directory(userId);
    await directory.create(recursive: true);
    final dot = source.path.lastIndexOf('.');
    final extension = dot == -1 ? '.jpg' : source.path.substring(dot);
    final fileName = '${photo.id}$extension';
    final target = await source.copy(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );

    try {
      await _db.transaction(() async {
        await _db
            .into(_db.savedProjects)
            .insertOnConflictUpdate(
              SavedProjectsCompanion.insert(
                userId: userId,
                projectId: photo.projectId,
                name: projectName,
              ),
            );
        await _db
            .into(_db.savedPhotos)
            .insertOnConflictUpdate(
              SavedPhotosCompanion.insert(
                userId: userId,
                photoId: photo.id,
                projectId: photo.projectId,
                uploaderId: photo.uploaderId,
                uploaderName: photo.uploaderName,
                createdAtUtcMs: photo.createdAt.toUtc().millisecondsSinceEpoch,
                savedAtUtcMs: DateTime.now().toUtc().millisecondsSinceEpoch,
                fileName: fileName,
                caption: Value(photo.caption),
              ),
            );
      });
    } catch (_) {
      await _deleteFile(target);
      rethrow;
    }
  }

  Future<void> remove(String userId, int photoId) async {
    final row =
        await (_db.select(_db.savedPhotos)..where(
              (p) => p.userId.equals(userId) & p.photoId.equals(photoId),
            ))
            .getSingleOrNull();
    if (row == null) return;

    await _db.transaction(() async {
      await (_db.delete(_db.savedPhotos)
            ..where((p) => p.userId.equals(userId) & p.photoId.equals(photoId)))
          .go();
      final remaining =
          await (_db.select(_db.savedPhotos)..where(
                (p) =>
                    p.userId.equals(userId) & p.projectId.equals(row.projectId),
              ))
              .get();
      if (remaining.isEmpty) {
        await (_db.delete(_db.savedProjects)..where(
              (p) =>
                  p.userId.equals(userId) & p.projectId.equals(row.projectId),
            ))
            .go();
      }
    });

    final directory = await _directory(userId);
    await _deleteFile(
      File('${directory.path}${Platform.pathSeparator}${row.fileName}'),
    );
  }

  Future<Directory> _directory(String userId) async {
    final documents = await _documentsDirectory();
    final separator = Platform.pathSeparator;
    return Directory(
      '${documents.path}${separator}saved_photos$separator$userId',
    );
  }

  SavedPhoto _toSavedPhoto(
    SavedPhotoRow row,
    String projectName,
    Directory directory,
  ) {
    return SavedPhoto(
      photo: ProjectPhoto(
        id: row.photoId,
        projectId: row.projectId,
        uploaderId: row.uploaderId,
        uploaderName: row.uploaderName,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row.createdAtUtcMs,
          isUtc: true,
        ).toLocal(),
        caption: row.caption,
      ),
      projectName: projectName,
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        row.savedAtUtcMs,
        isUtc: true,
      ).toLocal(),
      filePath: '${directory.path}${Platform.pathSeparator}${row.fileName}',
    );
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      return;
    }
  }
}
