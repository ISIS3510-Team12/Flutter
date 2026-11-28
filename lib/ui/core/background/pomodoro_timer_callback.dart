import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_notification_repository.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';

@pragma('vm:entry-point')
void pomodoroTimerStarted() {
  FlutterForegroundTask.setTaskHandler(PomodoroTaskHandler());
}

class PomodoroTaskHandler extends TaskHandler {
  (String, String)? _shown;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) => _tick();

  @override
  void onRepeatEvent(DateTime timestamp) => unawaited(_tick());

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}

  Future<void> _tick() async {
    final end = await FlutterForegroundTask.getData<int>(
      key: PomodoroNotificationRepository.endsAtKey,
    );
    final title = await FlutterForegroundTask.getData<String>(
      key: PomodoroNotificationRepository.titleKey,
    );
    var text = await FlutterForegroundTask.getData<String>(
      key: PomodoroNotificationRepository.textKey,
    );
    if (end != null) {
      final left = end - DateTime.now().millisecondsSinceEpoch;
      if (left <= 0) {
        await FlutterForegroundTask.stopService();
        return;
      }
      text = formatCountdown((left / 1000).ceil());
    }
    if (title == null || text == null || (title, text) == _shown) return;
    _shown = (title, text);
    await FlutterForegroundTask.updateService(
      notificationTitle: title,
      notificationText: text,
    );
  }
}
