import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/profile/settings_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

class SettingsViewModel extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSoundAndVibration(bool enabled) async {
    final current = state.value;
    if (current == null) return;
    await _persist(current.copyWith(soundAndVibrationEnabled: enabled));
  }

  Future<void> _persist(AppSettings updated) async {
    final previous = state.value;
    state = AsyncData(updated);
    final result = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).updateSettings(updated),
    );
    if (!ref.mounted) return;
    if (result.hasError && previous != null) state = AsyncData(previous);
  }
}
