import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_notification.dart';

@DataClassName('CachedNotificationRow')
@TableIndex(
  name: 'cached_notifications_user_time',
  columns: {#userId, #occurredAtUtcMs},
)
class CachedNotifications extends Table {
  TextColumn get userId => text()();
  TextColumn get id => text()();
  TextColumn get groupName => text()();
  TextColumn get title => text()();
  IntColumn get occurredAtUtcMs => integer()();
  TextColumn get type => textEnum<NotificationType>()();

  @override
  Set<Column> get primaryKey => {userId, id};

  @override
  bool get isStrict => true;
}
