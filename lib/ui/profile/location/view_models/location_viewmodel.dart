import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';

const notifyWithinOptions = [100, 250, 500, 750, 1000];
const defaultNotifyWithin = 500;

class LocationState {
  const LocationState({this.point, this.notifyWithin = defaultNotifyWithin});

  final LatLng? point;
  final int notifyWithin;

  bool get canSave => point != null;

  LocationState copyWith({LatLng? point, int? notifyWithin}) {
    return LocationState(
      point: point ?? this.point,
      notifyWithin: notifyWithin ?? this.notifyWithin,
    );
  }
}

class LocationViewModel extends AsyncNotifier<LocationState> {
  @override
  Future<LocationState> build() async {
    final saved = await ref.watch(locationRepositoryProvider).getLocation();
    if (saved == null) return const LocationState();
    return LocationState(
      point: LatLng(saved.latitude, saved.longitude),
      notifyWithin: saved.notifyWithin,
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

  Future<bool> save() async {
    final current = state.value;
    final point = current?.point;
    if (current == null || point == null) return false;
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
    return !result.hasError;
  }
}
