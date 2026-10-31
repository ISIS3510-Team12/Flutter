import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_user_locations.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';

part 'user_location_cache_dao.g.dart';

@DriftAccessor(tables: [CachedUserLocations])
class UserLocationCacheDao extends DatabaseAccessor<AppDatabase>
    with _$UserLocationCacheDaoMixin {
  UserLocationCacheDao({required AppDatabase db}) : super(db);

  Future<void> save(String userId, UserLocation location) {
    return into(cachedUserLocations).insertOnConflictUpdate(
      CachedUserLocationsCompanion.insert(
        userId: userId,
        latitude: location.latitude,
        longitude: location.longitude,
        notifyWithin: location.notifyWithin,
      ),
    );
  }

  Future<void> replace(String userId, UserLocation? location) {
    if (location == null) return remove(userId);
    return save(userId, location);
  }

  Future<UserLocation?> find(String userId) async {
    final query = select(cachedUserLocations)
      ..where((l) => l.userId.equals(userId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return UserLocation(
      latitude: row.latitude,
      longitude: row.longitude,
      notifyWithin: row.notifyWithin,
    );
  }

  Future<void> remove(String userId) {
    return (delete(
      cachedUserLocations,
    )..where((l) => l.userId.equals(userId))).go();
  }
}
