import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:team12_flutter_juggle/ui/core/utils/lru_cache.dart';

enum LocationAccess { granted, denied, permanentlyDenied, serviceDisabled }

class CurrentLocation {
  const CurrentLocation.found(LatLng this.point)
    : access = LocationAccess.granted;

  const CurrentLocation.unavailable(this.access) : point = null;

  const CurrentLocation.noFix() : point = null, access = LocationAccess.granted;

  final LatLng? point;
  final LocationAccess access;
}

class DeviceLocationRepository {
  DeviceLocationRepository({required LruCache<String, String> placeNameCache})
    : _placeNameCache = placeNameCache;

  final LruCache<String, String> _placeNameCache;

  Future<LocationAccess> requestWhileInUse() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isPermanentlyDenied) return LocationAccess.permanentlyDenied;
    if (!status.isGranted) return LocationAccess.denied;
    final serviceStatus = await Permission.locationWhenInUse.serviceStatus;
    if (!serviceStatus.isEnabled) return LocationAccess.serviceDisabled;
    return LocationAccess.granted;
  }

  Future<bool> hasBackgroundAccess() => Permission.locationAlways.isGranted;

  Future<bool> requestBackgroundAccess() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  Future<CurrentLocation> currentLocation() async {
    final access = await requestWhileInUse();
    if (access != LocationAccess.granted) {
      return CurrentLocation.unavailable(access);
    }
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return CurrentLocation.found(
        LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const CurrentLocation.noFix();
    }
  }

  Future<String?> placeName(LatLng point) {
    final key =
        '${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)}';
    return _placeNameCache
        .getOrLoad(key, () {
          _log('geocoder call $key');
          return _lookupPlaceName(point);
        })
        .then((name) {
          _log(
            '$key -> ${name ?? 'none'} '
            '(hits=${_placeNameCache.hits}, misses=${_placeNameCache.misses}, '
            'entries=${_placeNameCache.length})',
          );
          return name;
        });
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('Place name cache: $message');
  }

  Future<String?> _lookupPlaceName(LatLng point) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (placemarks.isEmpty) return null;
      final placemark = placemarks.first;
      final street = placemark.street;
      final label = street != null && street.isNotEmpty
          ? street
          : placemark.name;
      final locality = placemark.locality;
      final parts = <String>[
        if (label != null && label.isNotEmpty) label,
        if (locality != null &&
            locality.isNotEmpty &&
            !(label?.contains(locality) ?? false))
          locality,
      ];
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await geo.Geolocator.openLocationSettings();
  }
}
