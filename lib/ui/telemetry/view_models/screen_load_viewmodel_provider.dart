import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/telemetry/view_models/screen_load_viewmodel.dart';

final screenLoadViewModelProvider = NotifierProvider<ScreenLoadViewModel, void>(
  ScreenLoadViewModel.new,
);
