import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/today_summary.dart';

class DailyReminderRepository {
  DailyReminderRepository(this._notifications);

  static const _alarmId = 3001;
  static const _notificationId = 3002;
  static const _soundChannelId = 'daily_reminders';
  static const _silentChannelId = 'daily_reminders_silent';
  static const _maxListedTitles = 5;

  final FlutterLocalNotificationsPlugin _notifications;
  bool _alarmsReady = false;
  bool _notificationsReady = false;

  Future<void> schedule(String time, Function callback) async {
    await _initAlarms();
    final exact = await _canScheduleExact();
    await AndroidAlarmManager.oneShotAt(
      nextOccurrence(time, DateTime.now()),
      _alarmId,
      callback,
      exact: exact,
      allowWhileIdle: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  Future<void> cancel() async {
    await _initAlarms();
    await AndroidAlarmManager.cancel(_alarmId);
  }

  Future<bool> requestNotificationPermission() async {
    await _initNotifications();
    return await _androidNotifications()?.requestNotificationsPermission() ??
        true;
  }

  Future<bool> requestExactAlarmPermission() async {
    await _initNotifications();
    if (await _canScheduleExact()) return true;
    final android = _androidNotifications();
    return await android?.requestExactAlarmsPermission() ?? false;
  }

  Future<void> showReminder(
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
        .map((t) => '• $t');
    final extra = summary.titles.length - _maxListedTitles;
    final details = [body, ...listed, if (extra > 0) '+$extra more'].join('\n');
    await _notifications.show(
      id: _notificationId,
      title: 'Your daily task reminder',
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          withSound ? _soundChannelId : _silentChannelId,
          withSound ? 'Daily reminders' : 'Daily reminders (silent)',
          channelDescription: 'Daily summary of your pending tasks',
          importance: Importance.high,
          priority: Priority.high,
          playSound: withSound,
          enableVibration: withSound,
          styleInformation: BigTextStyleInformation(details),
        ),
      ),
    );
  }

  static DateTime nextOccurrence(String time, DateTime now) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    if (today.isAfter(now)) return today;
    return DateTime(now.year, now.month, now.day + 1, hour, minute);
  }

  AndroidFlutterLocalNotificationsPlugin? _androidNotifications() {
    return _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
  }

  Future<bool> _canScheduleExact() async {
    await _initNotifications();
    return await _androidNotifications()?.canScheduleExactNotifications() ??
        false;
  }

  Future<void> _initAlarms() async {
    if (_alarmsReady) return;
    await AndroidAlarmManager.initialize();
    _alarmsReady = true;
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
