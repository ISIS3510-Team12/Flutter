import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsViewModel extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.read(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(themeMode: mode));
  }

  Future<void> updateSoundAndVibration(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(soundAndVibrationEnabled: enabled));
  }

  Future<void> _persist(AppSettings updated) async {
    state = AsyncData(updated);
    await ref.read(settingsRepositoryProvider).updateSettings(updated);
  }
}
