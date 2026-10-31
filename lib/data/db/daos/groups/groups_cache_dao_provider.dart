import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/groups/groups_cache_dao.dart';

final groupsCacheDaoProvider = Provider<GroupsCacheDao>(
  (ref) => GroupsCacheDao(db: ref.watch(appDatabaseProvider)),
);
