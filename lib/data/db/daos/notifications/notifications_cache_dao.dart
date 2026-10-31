import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_notifications.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

part 'notifications_cache_dao.g.dart';

@DriftAccessor(tables: [CachedNotifications])
class NotificationsCacheDao extends DatabaseAccessor<AppDatabase>
    with _$NotificationsCacheDaoMixin {
  NotificationsCacheDao({required AppDatabase db}) : super(db);

  Future<void> replaceForUser(
    String userId,
    List<AppNotification> notifications,
  ) {
    return batch((batch) {
      batch.deleteWhere(cachedNotifications, (n) => n.userId.equals(userId));
      batch.insertAll(cachedNotifications, [
        for (final notification in notifications)
          _toCompanion(userId, notification),
      ]);
    });
  }

  Future<void> deleteById(String userId, String id) async {
    await (delete(
      cachedNotifications,
    )..where((n) => n.userId.equals(userId) & n.id.equals(id))).go();
  }

  Future<List<AppNotification>?> findForUser(String userId) async {
    final query = select(cachedNotifications)
      ..where((n) => n.userId.equals(userId))
      ..orderBy([(n) => OrderingTerm.desc(n.occurredAtUtcMs)]);
    final rows = await query.get();
    return rows.isEmpty ? null : rows.map(_toNotification).toList();
  }

  Stream<List<AppNotification>> watchBetween(
    String userId, {
    required int startMs,
    required int endMs,
  }) {
    final query = select(cachedNotifications)
      ..where(
        (n) =>
            n.userId.equals(userId) &
            n.occurredAtUtcMs.isBiggerOrEqualValue(startMs) &
            n.occurredAtUtcMs.isSmallerThanValue(endMs),
      )
      ..orderBy([(n) => OrderingTerm.desc(n.occurredAtUtcMs)]);
    return query.watch().map((rows) => rows.map(_toNotification).toList());
  }

  Future<bool> refresh(
    String userId,
    Future<List<AppNotification>> Function() fetch,
  ) async {
    try {
      final notifications = await fetch();
      await replaceForUser(userId, notifications);
      return true;
    } on Exception catch (error, stackTrace) {
      debugPrint('Notifications cache refresh failed: $error\n$stackTrace');
      return false;
    }
  }

  CachedNotificationsCompanion _toCompanion(
    String userId,
    AppNotification notification,
  ) {
    return CachedNotificationsCompanion.insert(
      userId: userId,
      id: notification.id,
      groupName: notification.groupName,
      title: notification.title,
      occurredAtUtcMs: notification.timestamp.toUtc().millisecondsSinceEpoch,
      type: notification.type,
    );
  }

  AppNotification _toNotification(CachedNotificationRow row) {
    return AppNotification(
      id: row.id,
      groupName: row.groupName,
      title: row.title,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        row.occurredAtUtcMs,
        isUtc: true,
      ).toLocal(),
      type: row.type,
    );
  }
}
