import 'package:permission_handler/permission_handler.dart';

enum LocationAccess { granted, denied, permanentlyDenied, serviceDisabled }

class DeviceLocationRepository {
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

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
