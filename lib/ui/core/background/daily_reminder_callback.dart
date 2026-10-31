import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/daily_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';

@pragma('vm:entry-point')
Future<void> dailyReminderTriggered() async {
  try {
    await setupDependencies();
    final container = ProviderContainer();
    try {
      final reminders = container.read(dailyReminderRepositoryProvider);
      final settings = await container
          .read(settingsRepositoryProvider)
          .getSettings();
      final time = settings.dailyReminderTime;
      if (!settings.dailyRemindersEnabled || time == null) return;

      await reminders.schedule(time, dailyReminderTriggered);

      final auth = FirebaseAuth.instance;
      final user =
          auth.currentUser ??
          await auth.authStateChanges().first.timeout(
            const Duration(seconds: 5),
            onTimeout: () => null,
          );
      if (user == null) return;

      final summary = await container
          .read(taskRepositoryProvider)
          .getTodaySummary();
      if (summary.pendingCount == 0) return;
      await reminders.showReminder(
        summary,
        withSound: settings.soundAndVibrationEnabled,
      );
    } finally {
      container.dispose();
    }
  } catch (_) {
    return;
  }
}
