import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/data/repositories/location/arrival_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';
import 'package:team12_flutter_juggle/ui/core/background/arrival_geofence_callback.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_viewmodel.freezed.dart';

enum SaveOutcome {
  saved,
  savedWithoutLocationPermission,
  savedWithoutBackgroundPermission,
  savedWithoutNotificationPermission,
  savedWithoutReminders,
  failed,
}

const defaultNotifyWithin = 500;

const notifyWithinOptions = [100, 250, 500, 750, 1000];

@freezed
abstract class LocationState with _$LocationState {
  const LocationState._();

  const factory LocationState({
    UserLocation? saved,
    LatLng? point,
    @Default(defaultNotifyWithin) int notifyWithin,
    @Default(false) bool remindersActive,
  }) = _LocationState;

  bool get hasChanges {
    final current = saved;
    final selected = point;
    if (selected == null) return false;
    if (current == null) return true;
    return current.latitude != selected.latitude ||
        current.longitude != selected.longitude ||
        current.notifyWithin != notifyWithin;
  }

  bool get canSave => point != null && (hasChanges || !remindersActive);
}

class LocationViewModel extends AsyncNotifier<LocationState> {
  @override
  Future<LocationState> build() async {
    final saved = await ref.watch(locationRepositoryProvider).getLocation();
    if (saved == null) return const LocationState();
    return LocationState(
      saved: saved,
      point: LatLng(saved.latitude, saved.longitude),
      notifyWithin: saved.notifyWithin,
      remindersActive: await _remindersActive(),
    );
  }

  void selectPoint(LatLng point) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(point: point));
  }

  void updateNotifyWithin(int meters) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(notifyWithin: meters));
  }

  Future<CurrentLocation> locateMe() =>
      ref.read(deviceLocationRepositoryProvider).currentLocation();

  Future<SaveOutcome> save() async {
    final current = state.value;
    final point = current?.point;
    if (current == null || point == null) return SaveOutcome.failed;
    final repository = ref.read(locationRepositoryProvider);
    final result = await AsyncValue.guard(
      () => repository.saveLocation(
        UserLocation(
          latitude: point.latitude,
          longitude: point.longitude,
          notifyWithin: current.notifyWithin,
        ),
      ),
    );
    if (result.hasError) return SaveOutcome.failed;
    final saved = result.requireValue;
    final outcome = await _enableReminders(saved);
    if (ref.mounted) {
      state = AsyncData(
        LocationState(
          saved: saved,
          point: point,
          notifyWithin: saved.notifyWithin,
          remindersActive: outcome == SaveOutcome.saved,
        ),
      );
    }
    return outcome;
  }

  Future<bool> _remindersActive() async {
    final result = await AsyncValue.guard(
      () => ref.read(arrivalReminderRepositoryProvider).isEnabled(),
    );
    return result.value ?? false;
  }

  Future<SaveOutcome> _enableReminders(UserLocation location) async {
    final device = ref.read(deviceLocationRepositoryProvider);
    final reminders = ref.read(arrivalReminderRepositoryProvider);
    try {
      if (await device.requestWhileInUse() != LocationAccess.granted) {
        return SaveOutcome.savedWithoutLocationPermission;
      }
      if (!await device.requestBackgroundAccess()) {
        return SaveOutcome.savedWithoutBackgroundPermission;
      }
      if (!await reminders.requestNotificationPermission()) {
        return SaveOutcome.savedWithoutNotificationPermission;
      }
      await reminders.enable(location, arrivalGeofenceTriggered);
      return SaveOutcome.saved;
    } catch (_) {
      return SaveOutcome.savedWithoutReminders;
    }
  }
}
