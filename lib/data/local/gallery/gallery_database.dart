import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:team12_flutter_juggle/data/local/gallery/saved_gallery_tables.dart';

part 'gallery_database.g.dart';

@DriftDatabase(tables: [SavedProjects, SavedPhotos])
class GalleryDatabase extends _$GalleryDatabase {
  GalleryDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'juggle_gallery'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
