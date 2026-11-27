import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/gallery/project_photos_cache_dao.dart';

final projectPhotosCacheDaoProvider = Provider<ProjectPhotosCacheDao>(
  (ref) => ProjectPhotosCacheDao(db: ref.watch(appDatabaseProvider)),
);
