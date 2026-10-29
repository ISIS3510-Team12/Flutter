import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_groups.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_notifications.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_projects.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_tasks.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [CachedTasks, CachedNotifications, CachedGroups, CachedProjects],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  Future<void> clearCache() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      for (final table in allTables.toList()) {
        await m.drop(table);
      }
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
