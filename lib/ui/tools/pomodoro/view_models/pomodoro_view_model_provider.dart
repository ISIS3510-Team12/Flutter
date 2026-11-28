import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/view_models/pomodoro_view_model.dart';

final pomodoroViewModelProvider =
    NotifierProvider.autoDispose<PomodoroViewModel, PomodoroUiState>(
      PomodoroViewModel.new,
    );
