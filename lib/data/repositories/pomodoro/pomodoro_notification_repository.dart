import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';
import 'package:timezone/timezone.dart' as tz;

class PomodoroNotificationRepository {
  PomodoroNotificationRepository(this._notifications, this._timerCallback);

  static const endsAtKey = 'pomodoro_ends_at';
  static const titleKey = 'pomodoro_title';
  static const textKey = 'pomodoro_text';
  static const _legacyStatusId = 4001;
  static const _finishedId = 4002;
  static const _serviceId = 4003;

  final FlutterLocalNotificationsPlugin _notifications;
  final Function _timerCallback;
  Future<void> _queue = Future.value();
  PomodoroTimer? _applied;
  bool _ready = false;
  bool _askedPermissions = false;

  Future<void> show(PomodoroTimer timer, {bool force = false}) =>
      _enqueue(() async {
        final previous = _applied;
        if (!force &&
            previous != null &&
            _isSame(previous, timer) &&
            !await _isServiceMissing(timer)) {
          return;
        }
        await _init();
        await _apply(timer, previous);
        _applied = timer;
      });

  Future<bool> requestPermissions() async {
    if (_askedPermissions) return false;
    _askedPermissions = true;
    await _enqueue(() async {
      await _init();
      final android = _android();
      await android?.requestNotificationsPermission();
      if (await android?.canScheduleExactNotifications() == false) {
        await android?.requestExactAlarmsPermission();
      }
    });
    return true;
  }

  Future<void> _apply(PomodoroTimer timer, PomodoroTimer? previous) async {
    final end = timer.endsAt;
    final now = DateTime.now();
    switch (timer.status) {
      case PomodoroStatus.running:
        await _notifications.cancel(id: _finishedId);
        if (end == null || !end.isAfter(now)) return;
        await _scheduleFinished(timer, end);
        final left = (end.difference(now).inMilliseconds / 1000).ceil();
        await _showInService(timer, formatCountdown(left), end: end);
      case PomodoroStatus.finished:
        await _stopService();
        final endedNow = previous?.status == PomodoroStatus.running;
        if (endedNow && !await _canScheduleExact()) {
          await _notifications.cancel(id: _finishedId);
          await _showFinished(timer);
        } else if (previous?.endsAt?.isAfter(now) ?? false) {
          await _notifications.cancel(id: _finishedId);
        }
      case PomodoroStatus.paused:
        await _notifications.cancel(id: _finishedId);
        final left = formatCountdown(timer.remainingSeconds ?? 0);
        await _showInService(timer, '$left · Paused');
      case PomodoroStatus.idle:
        await _notifications.cancel(id: _finishedId);
        final isReset = timer.phase == PomodoroPhase.focus && timer.cycle == 1;
        if (isReset) return _stopService();
        await _showInService(timer, 'Press play to start');
    }
  }

  String _title(PomodoroTimer timer) =>
      'Pomodoro · ${timer.phase == PomodoroPhase.focus ? 'Focus' : 'Break'}';

  Future<void> _showInService(
    PomodoroTimer timer,
    String text, {
    DateTime? end,
  }) async {
    final title = _title(timer);
    await FlutterForegroundTask.saveData(key: titleKey, value: title);
    await FlutterForegroundTask.saveData(key: textKey, value: text);
    if (end == null) {
      await FlutterForegroundTask.removeData(key: endsAtKey);
    } else {
      await FlutterForegroundTask.saveData(
        key: endsAtKey,
        value: end.millisecondsSinceEpoch,
      );
    }
    final ServiceRequestResult result;
    if (await FlutterForegroundTask.isRunningService) {
      result = await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } else {
      result = await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: [ForegroundServiceTypes.specialUse],
        notificationTitle: title,
        notificationText: text,
        callback: _timerCallback,
      );
    }
    if (result is ServiceRequestFailure) throw result.error;
  }

  Future<void> _stopService() async {
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
  }

  Future<bool> _isServiceMissing(PomodoroTimer timer) async =>
      timer.status == PomodoroStatus.running &&
      !await FlutterForegroundTask.isRunningService;

  Future<void> _scheduleFinished(PomodoroTimer timer, DateTime end) async {
    final exact = await _canScheduleExact();
    final (title, body) = _finishedText(timer);
    await _notifications.zonedSchedule(
      id: _finishedId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(end, tz.UTC),
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: _finishedDetails,
    );
  }

  Future<void> _showFinished(PomodoroTimer timer) {
    final (title, body) = _finishedText(timer);
    return _notifications.show(
      id: _finishedId,
      title: title,
      body: body,
      notificationDetails: _finishedDetails,
    );
  }

  static const _finishedDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'pomodoro_finished',
      'Pomodoro alerts',
      channelDescription: 'Alerts when a focus session or break ends',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  (String, String) _finishedText(PomodoroTimer timer) => switch (timer.phase) {
    PomodoroPhase.focus => ('Focus complete', 'Time for your break.'),
    PomodoroPhase.shortBreak when timer.cycle == pomodoroCycles => (
      'All cycles complete',
      'Great work!',
    ),
    PomodoroPhase.shortBreak => ('Break over', 'Ready to focus again?'),
  };

  Future<bool> _canScheduleExact() async =>
      await _android()?.canScheduleExactNotifications() ?? false;

  bool _isSame(PomodoroTimer a, PomodoroTimer b) =>
      a.status == b.status &&
      a.phase == b.phase &&
      a.cycle == b.cycle &&
      a.endsAt == b.endsAt &&
      a.remainingSeconds == b.remainingSeconds;

  Future<void> _enqueue(Future<void> Function() action) =>
      _queue = _queue.then((_) async {
        try {
          await action();
        } catch (error, stack) {
          debugPrint('Pomodoro notification failed: $error\n$stack');
        }
      });

  AndroidFlutterLocalNotificationsPlugin? _android() => _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> _init() async {
    if (_ready) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'pomodoro_service',
        channelName: 'Pomodoro timer',
        channelDescription: 'Countdown of the running Pomodoro phase',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
        showWhen: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        allowWakeLock: true,
      ),
    );
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _notifications.cancel(id: _legacyStatusId);
    _ready = true;
  }
}
