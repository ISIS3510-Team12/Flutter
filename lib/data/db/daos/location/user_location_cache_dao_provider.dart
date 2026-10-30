import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/location/user_location_cache_dao.dart';

final userLocationCacheDaoProvider = Provider<UserLocationCacheDao>(
  (ref) => UserLocationCacheDao(db: ref.watch(appDatabaseProvider)),
);
