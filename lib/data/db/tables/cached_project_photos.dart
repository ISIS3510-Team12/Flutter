import 'package:drift/drift.dart';

@DataClassName('CachedProjectPhotoRow')
@TableIndex(
  name: 'cached_project_photos_user_project',
  columns: {#userId, #projectId},
)
class CachedProjectPhotos extends Table {
  TextColumn get userId => text()();
  IntColumn get id => integer()();
  IntColumn get projectId => integer()();
  TextColumn get uploaderId => text()();
  TextColumn get uploaderName => text()();
  IntColumn get createdAtUtcMs => integer()();
  TextColumn get caption => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId, id};

  @override
  bool get isStrict => true;
}
