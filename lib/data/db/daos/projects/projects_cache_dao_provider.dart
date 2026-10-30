import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/projects/projects_cache_dao.dart';

final projectsCacheDaoProvider = Provider<ProjectsCacheDao>(
  (ref) => ProjectsCacheDao(db: ref.watch(appDatabaseProvider)),
);
