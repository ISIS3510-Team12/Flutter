import 'package:flutter/foundation.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({
    required SettingsRepository settingsRepository,
    required VoidCallback onSignedOut,
  }) : _settingsRepository = settingsRepository,
       _onSignedOut = onSignedOut {
    _load();
  }

  final SettingsRepository _settingsRepository;
  final VoidCallback _onSignedOut;

  AppSettings? _settings;
  AppSettings? get settings => _settings;

  bool isSigningOut = false;

  Future<void> _load() async {
    _settings = await _settingsRepository.getSettings();
    notifyListeners();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    if (_settings == null) return;
    await _persist(_settings!.copyWith(themeMode: mode));
  }

  Future<void> updateSoundAndVibration(bool enabled) async {
    if (_settings == null) return;
    await _persist(_settings!.copyWith(soundAndVibrationEnabled: enabled));
  }

  Future<void> _persist(AppSettings updated) async {
    _settings = updated;
    await _settingsRepository.updateSettings(updated);
    notifyListeners();
  }

  Future<void> signOut() async {
    isSigningOut = true;
    notifyListeners();
    // TODO: call the real auth service here (clear session/tokens)
    _onSignedOut();
    isSigningOut = false;
    notifyListeners();
  }
}
