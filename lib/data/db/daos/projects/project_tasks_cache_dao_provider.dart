
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/project_tasks_cache_dao.dart';

final projectTasksCacheDaoProvider = Provider<ProjectTasksCacheDao>(
  (ref) => ProjectTasksCacheDao(
    db: ref.watch(appDatabaseProvider),
  ),
);
