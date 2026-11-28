import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_notification_repository.dart';
import 'package:team12_flutter_juggle/ui/core/background/pomodoro_timer_callback.dart';

final pomodoroNotificationRepositoryProvider = Provider(
  (ref) => PomodoroNotificationRepository(
    FlutterLocalNotificationsPlugin(),
    pomodoroTimerStarted,
  ),
);
