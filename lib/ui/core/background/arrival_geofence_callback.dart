import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_geofence/native_geofence.dart';
import 'package:team12_flutter_juggle/data/repositories/location/arrival_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';

@pragma('vm:entry-point')
Future<void> arrivalGeofenceTriggered(GeofenceCallbackParams params) async {
  if (params.event != GeofenceEvent.enter) return;
  try {
    await setupBackgroundDependencies();
    final auth = FirebaseAuth.instance;
    final user =
        auth.currentUser ??
        await auth.authStateChanges().first.timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        );
    if (user == null) return;

    final container = ProviderContainer();
    try {
      final summary = await container
          .read(taskRepositoryProvider)
          .getTodaySummary();
      if (summary.pendingCount == 0) return;
      final settings = await container
          .read(settingsRepositoryProvider)
          .getSettings();
      await container
          .read(arrivalReminderRepositoryProvider)
          .showArrivalNotification(
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
