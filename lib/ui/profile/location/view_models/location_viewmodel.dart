import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:team12_flutter_juggle/data/db/daos/location/user_location_cache_dao.dart';
import 'package:team12_flutter_juggle/data/db/daos/location/user_location_cache_dao_provider.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/data/repositories/location/arrival_reminder_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/location/device_location_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/background/arrival_geofence_callback.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/network/network_first.dart';
import 'package:team12_flutter_juggle/ui/core/sync/sync_providers.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_viewmodel.freezed.dart';

enum SaveOutcome {
  saved,
  savedWithoutLocationPermission,
  savedWithoutBackgroundPermission,
  savedWithoutNotificationPermission,
  savedWithoutReminders,
  savedOffline,
  failed,
}

typedef _Persisted = ({UserLocation location, bool queued});

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
  String? _userId;

  UserLocationCacheDao get _cache => ref.read(userLocationCacheDaoProvider);

  @override
  Future<LocationState> build() async {
    final repository = ref.watch(locationRepositoryProvider);
    final user = await ref.watch(currentUserProvider.future);
    final userId = _userId = user?.userId;
    final saved = userId == null
        ? await repository.getLocation()
        : await _load(userId);
    if (saved == null) return const LocationState();
    return LocationState(
      saved: saved,
      point: LatLng(saved.latitude, saved.longitude),
      notifyWithin: saved.notifyWithin,
      remindersActive: await _remindersActive(),
    );
  }

  Future<UserLocation?> _load(String userId) async {
    final pending = _pendingLocation(userId);
    if (pending != null) {
      await saveQuietly(() => _cache.save(userId, pending));
      return pending;
    }
    try {
      final result = await networkFirst<UserLocation?>(
        isOnline: ref.read(isOnlineProvider),
        fetch: ref.read(locationRepositoryProvider).getLocation,
        save: (location) => _cache.replace(userId, location),
        fallback: () => _cache.find(userId),
      );
      return result.value;
    } catch (error) {
      if (!isOfflineFailure(error)) rethrow;
      return null;
    }
  }

  UserLocation? _pendingLocation(String userId) {
    final ops = ref.read(outboxStoreProvider).forUser(userId);
    return ops
        .where((op) => op.type == PendingOpType.saveLocation)
        .lastOrNull
        ?.location;
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
    final location = UserLocation(
      latitude: point.latitude,
      longitude: point.longitude,
      notifyWithin: current.notifyWithin,
    );
    final result = await _persist(location);
    if (result == null) return SaveOutcome.failed;
    final saved = result.location;
    final reminders = await _enableReminders(saved);
    final outcome = result.queued && reminders == SaveOutcome.saved
        ? SaveOutcome.savedOffline
        : reminders;
    if (ref.mounted) {
      state = AsyncData(
        LocationState(
          saved: saved,
          point: point,
          notifyWithin: saved.notifyWithin,
          remindersActive: reminders == SaveOutcome.saved,
        ),
      );
    }
    return outcome;
  }

  Future<_Persisted?> _persist(UserLocation location) async {
    final userId = _userId;
    if (userId != null && !ref.read(isOnlineProvider)) {
      return _queue(userId, location);
    }
    try {
      final saved = await ref
          .read(locationRepositoryProvider)
          .saveLocation(location);
      if (userId != null) {
        await saveQuietly(() => _cache.save(userId, saved));
        await saveQuietly(
          ref.read(outboxSyncServiceProvider).discardSaveLocation,
        );
      }
      return (location: saved, queued: false);
    } catch (error) {
      if (userId == null || !isOfflineFailure(error)) return null;
      return _queue(userId, location);
    }
  }

  Future<_Persisted?> _queue(String userId, UserLocation location) async {
    try {
      await ref.read(outboxSyncServiceProvider).enqueueSaveLocation(location);
    } catch (_) {
      return null;
    }
    await saveQuietly(() => _cache.save(userId, location));
    return (location: location, queued: true);
  }

  Future<void> discardPendingSync(String opId) async {
    await ref.read(outboxSyncServiceProvider).discard(opId);
    ref.invalidateSelf();
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
