import 'package:team12_flutter_juggle/data/services/profile/settings_local_service.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsRepository {
  SettingsRepository(this._localService);

  final SettingsLocalService _localService;

  Future<AppSettings> getSettings() {
    return _localService.readSettings();
  }

  Future<void> updateSettings(AppSettings settings) {
    return _localService.writeSettings(settings);
  }
}
