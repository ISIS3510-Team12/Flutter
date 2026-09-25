import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/profile/app_settings.dart';

import 'settings_viewmodel.dart';

final settingsViewModelProvider =
    AsyncNotifierProvider.autoDispose<SettingsViewModel, AppSettings>(
      SettingsViewModel.new,
    );
