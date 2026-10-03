import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/location/arrival_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/background/arrival_geofence_callback.dart';

final arrivalReminderSyncProvider = FutureProvider<void>((ref) async {
  try {
    final user = await ref.watch(authStateProvider.future);
    final reminders = ref.read(arrivalReminderRepositoryProvider);
    if (user == null) {
      await reminders.disable();
      return;
    }
    final location = await ref.read(locationRepositoryProvider).getLocation();
    if (location == null) {
      await reminders.disable();
      return;
    }
    final canRunInBackground = await ref
        .read(deviceLocationRepositoryProvider)
        .hasBackgroundAccess();
    if (canRunInBackground) {
      await reminders.enable(location, arrivalGeofenceTriggered);
    }
  } catch (_) {
    return;
  }
});
