import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao.dart';

final tasksCacheDaoProvider = Provider<TasksCacheDao>(
  (ref) => TasksCacheDao(db: ref.watch(appDatabaseProvider)),
);
