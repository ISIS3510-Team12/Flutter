import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/today_summary.dart';

typedef GeofenceCallback = Future<void> Function(GeofenceCallbackParams params);

class ArrivalReminderRepository {
  ArrivalReminderRepository(this._notifications);

  static const geofenceId = 'arrival-reminder';
  static const _notificationId = 2001;
  static const _soundChannelId = 'arrival_reminders';
  static const _silentChannelId = 'arrival_reminders_silent';
  static const _maxListedTitles = 5;

  final FlutterLocalNotificationsPlugin _notifications;
  bool _geofenceReady = false;
  bool _notificationsReady = false;

  Future<void> enable(UserLocation location, GeofenceCallback callback) async {
    await _initGeofence();
    await _removeIfPresent();
    await NativeGeofenceManager.instance.createGeofence(
      Geofence(
        id: geofenceId,
        location: Location(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
        radiusMeters: location.notifyWithin.toDouble(),
        triggers: {GeofenceEvent.enter},
        iosSettings: const IosGeofenceSettings(initialTrigger: false),
        androidSettings: const AndroidGeofenceSettings(
          initialTriggers: {},
          notificationResponsiveness: Duration(minutes: 1),
        ),
      ),
      callback,
    );
  }

  Future<void> disable() async {
    await _initGeofence();
    await _removeIfPresent();
  }

  Future<bool> isEnabled() async {
    await _initGeofence();
    final active = await NativeGeofenceManager.instance
        .getRegisteredGeofences();
    return active.any((geofence) => geofence.id == geofenceId);
  }

  Future<bool> requestNotificationPermission() async {
    await _initNotifications();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  Future<void> showArrivalNotification(
    TodaySummary summary, {
    required bool withSound,
  }) async {
    await _initNotifications();
    final parts = <String>[
      if (summary.todayCount > 0) '${summary.todayCount} due today',
      if (summary.overdueCount > 0) '${summary.overdueCount} overdue',
    ];
    final body = parts.isEmpty
        ? '${summary.pendingCount} pending tasks'
        : parts.join(' and ');
    final listed = summary.titles
        .take(_maxListedTitles)
        .map((t) => '\u2022 $t');
    final extra = summary.titles.length - _maxListedTitles;
    final details = [body, ...listed, if (extra > 0) '+$extra more'].join('\n');
    await _notifications.show(
      id: _notificationId,
      title: 'Tasks waiting for you',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          withSound ? _soundChannelId : _silentChannelId,
          withSound ? 'Arrival reminders' : 'Arrival reminders (silent)',
          channelDescription:
              'Pending tasks when you arrive at your saved place',
          importance: Importance.high,
          priority: Priority.high,
          playSound: withSound,
          enableVibration: withSound,
          styleInformation: BigTextStyleInformation(details),
        ),
      ),
    );
  }

  Future<void> _removeIfPresent() async {
    try {
      await NativeGeofenceManager.instance.removeGeofenceById(geofenceId);
    } on NativeGeofenceException {
      return;
    }
  }

  Future<void> _initGeofence() async {
    if (_geofenceReady) return;
    await NativeGeofenceManager.instance.initialize();
    _geofenceReady = true;
  }

  Future<void> _initNotifications() async {
    if (_notificationsReady) return;
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _notificationsReady = true;
  }
}
