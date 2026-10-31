
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/daily_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';
import 'package:team12_flutter_juggle/ui/core/background/daily_reminder_callback.dart';

class SettingsViewModel extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSoundAndVibration(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    await _persist(
      current.copyWith(soundAndVibrationEnabled: enabled),
      () => ref
          .read(settingsRepositoryProvider)
          .updateSoundAndVibration(enabled),
    );
  }

  Future<void> updateDailyReminders(bool enabled) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      dailyRemindersEnabled: enabled,
      clearDailyReminderTime: !enabled,
    );

    await _persist(
      updated,
      () => ref
          .read(settingsRepositoryProvider)
          .updateDailyReminders(enabled),
    );

    if (enabled) {
      final reminders = ref.read(dailyReminderRepositoryProvider);
      await reminders.requestNotificationPermission();
      await reminders.requestExactAlarmPermission();
    }
    await _syncDailyReminder();
  }

  Future<void> updateDailyReminderTime(String time) async {
    final current = state.value;
    if (current == null) return;

    await _persist(
      current.copyWith(dailyReminderTime: time),
      () => ref
          .read(settingsRepositoryProvider)
          .updateDailyReminderTime(time),
    );

    await _syncDailyReminder();
  }

  Future<void> _syncDailyReminder() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null) return;

    final reminders = ref.read(dailyReminderRepositoryProvider);
    final time = current.dailyReminderTime;
    if (current.dailyRemindersEnabled && time != null) {
      await reminders.schedule(time, dailyReminderTriggered);
    } else {
      await reminders.cancel();
    }
  }

  Future<void> _persist(
    AppSettings updated,
    Future<void> Function() save,
  ) async {
    final previous = state.value;

    state = AsyncData(updated);

    final result = await AsyncValue.guard(save);

    if (!ref.mounted) return;

    if (result.hasError && previous != null) {
      state = AsyncData(previous);
    }
  }
}
