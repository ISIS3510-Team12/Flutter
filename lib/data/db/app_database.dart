import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_groups.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_notifications.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_projects.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_tasks.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_task_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_tasks.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_user_locations.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_list_loads.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CachedTasks,
    CachedNotifications,
    CachedGroups,
    CachedProjects,
    CachedGroupLoads,
    CachedUserLocations,
    CachedProjectGroupLoads,
    CachedProjectTasks,
    CachedProjectTaskLoads,
    CachedGroupListLoads,
  ],
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