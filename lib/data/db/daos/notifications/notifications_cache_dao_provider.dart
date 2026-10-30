import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/notifications/notifications_cache_dao.dart';

final notificationsCacheDaoProvider = Provider<NotificationsCacheDao>(
  (ref) => NotificationsCacheDao(db: ref.watch(appDatabaseProvider)),
);
