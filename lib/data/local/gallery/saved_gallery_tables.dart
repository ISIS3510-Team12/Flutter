import 'package:drift/drift.dart';

@DataClassName('SavedProjectRow')
class SavedProjects extends Table {
  TextColumn get userId => text()();
  IntColumn get projectId => integer()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {userId, projectId};

  @override
  bool get isStrict => true;
}

@DataClassName('SavedPhotoRow')
@TableIndex(name: 'saved_photos_user_project', columns: {#userId, #projectId})
class SavedPhotos extends Table {
  TextColumn get userId => text()();
  IntColumn get photoId => integer()();
  IntColumn get projectId => integer()();
  TextColumn get uploaderId => text()();
  TextColumn get uploaderName => text()();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get savedAtUtcMs => integer()();
  TextColumn get fileName => text()();
  TextColumn get caption => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId, photoId};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (user_id, project_id) '
        'REFERENCES saved_projects (user_id, project_id) ON DELETE CASCADE',
  ];

  @override
  bool get isStrict => true;
}
