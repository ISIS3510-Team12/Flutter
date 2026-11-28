import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_groups.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_notifications.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_projects.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_group_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_photo_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_photos.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_tasks.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_project_task_loads.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_tasks.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_user_locations.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_group_list_loads.dart';

import 'package:team12_flutter_juggle/data/db/tables/cached_wheels.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_wheel_options.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_spin_history.dart';

import 'package:team12_flutter_juggle/data/db/daos/decision_wheel/decision_wheel_dao.dart';

import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';

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
    CachedProjectPhotos,
    CachedProjectPhotoLoads,
    Wheels,
    WheelOptions,
    SpinHistory,
  ],
  daos: [
    DecisionWheelDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

  Future<void> clearCache() {
    return transaction(() async {
      await delete(cachedTasks).go();
      await delete(cachedNotifications).go();
      await delete(cachedGroups).go();
      await delete(cachedProjects).go();
      await delete(cachedGroupLoads).go();
      await delete(cachedUserLocations).go();
      await delete(cachedProjectGroupLoads).go();
      await delete(cachedProjectTasks).go();
      await delete(cachedProjectTaskLoads).go();
      await delete(cachedGroupListLoads).go();
      await delete(cachedProjectPhotos).go();
      await delete(cachedProjectPhotoLoads).go();
    });
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 5) {
            await m.createTable(wheels);
            await m.createTable(wheelOptions);
            await m.createTable(spinHistory);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
