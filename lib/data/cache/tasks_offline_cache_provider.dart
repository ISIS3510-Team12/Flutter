import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/cache/tasks_offline_cache.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/tasks/tasks_cache_dao_provider.dart';

final tasksOfflineCacheProvider = Provider<TasksOfflineCache>(
  (ref) => TasksOfflineCache(
    groups: ref.watch(groupsCacheDaoProvider),
    projects: ref.watch(projectsCacheDaoProvider),
    tasks: ref.watch(tasksCacheDaoProvider),
  ),
);
