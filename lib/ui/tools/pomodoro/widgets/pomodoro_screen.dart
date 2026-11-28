import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/view_models/pomodoro_view_model.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/view_models/pomodoro_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/widgets/duration_settings_card.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/widgets/timer_dial.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroViewModelProvider);
    final viewModel = ref.read(pomodoroViewModelProvider.notifier);
    final theme = Theme.of(context);
    final timer = state.timer;
    final colors = timer.completedAllCycles
        ? theme.colorScheme.copyWith(
            primary: theme.colorScheme.tertiary,
            onPrimary: theme.colorScheme.onTertiary,
          )
        : timer.phase == PomodoroPhase.shortBreak
        ? theme.colorScheme.copyWith(
            primary: theme.colorScheme.secondary,
            onPrimary: theme.colorScheme.onSecondary,
          )
        : theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.tools),
        ),
        title: Text(
          'Pomodoro Timer',
          style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: Theme(
              data: theme.copyWith(colorScheme: colors),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _title(timer),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colors.primary,
                            ),
                          ),
                          Text(
                            _subtitle(timer),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TimerDial(
                              remainingSeconds: state.remainingSeconds,
                              progress: state.progress,
                              cycle: timer.cycle,
                              completed: timer.completedAllCycles,
                              caption: _caption(state),
                              size: min(
                                min(constraints.maxWidth - 48, 300.0),
                                max(constraints.maxHeight * 0.55, 220.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _Controls(state: state, viewModel: viewModel),
                          const SizedBox(height: 16),
                          DurationSettingsCard(
                            settings: state.settings,
                            enabled: state.canEditSettings,
                            onFocusChanged: viewModel.setFocusMinutes,
                            onBreakChanged: viewModel.setBreakMinutes,
                          ),
                          if (!state.canEditSettings) ...[
                            const SizedBox(height: 8),
                            const _Note('Reset the timer to change durations.'),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  String _title(PomodoroTimer timer) {
    if (timer.completedAllCycles) return 'All Cycles Complete';
    final isFocus = timer.phase == PomodoroPhase.focus;
    if (timer.status == PomodoroStatus.finished) {
      return isFocus ? 'Focus Complete' : 'Break Over';
    }
    return isFocus ? 'Study Session' : 'Break Time';
  }

  String _subtitle(PomodoroTimer timer) {
    if (timer.completedAllCycles) {
      return 'Great work! Press play to start a new round';
    }
    final isFocus = timer.phase == PomodoroPhase.focus;
    if (timer.status == PomodoroStatus.finished) {
      return isFocus
          ? 'Press play to start your break'
          : 'Press play to start focusing';
    }
    return isFocus
        ? 'Stay focused on your task'
        : "You're on a break. Rest and recharge";
  }

  String _caption(PomodoroUiState state) {
    if (state.timer.completedAllCycles) {
      return '$pomodoroCycles of $pomodoroCycles cycles done';
    }
    return state.timer.phase == PomodoroPhase.focus
        ? 'Then ${state.settings.breakMinutes} min short break'
        : 'Then ${state.settings.focusMinutes} min focus';
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.viewModel});

  final PomodoroUiState state;
  final PomodoroViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final secondary = IconButton.styleFrom(
      backgroundColor: pomodoroTint(colors),
      foregroundColor: colors.primary,
      fixedSize: const Size.square(48),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          style: secondary,
          tooltip: 'Reset',
          onPressed: viewModel.reset,
          icon: const Icon(Icons.replay),
        ),
        const SizedBox(width: 20),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            fixedSize: const Size.square(64),
          ),
          iconSize: 28,
          tooltip: switch (state.timer.status) {
            PomodoroStatus.running => 'Pause',
            PomodoroStatus.paused => 'Resume',
            PomodoroStatus.idle || PomodoroStatus.finished => 'Start',
          },
          onPressed: viewModel.toggle,
          icon: Icon(state.isRunning ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(width: 20),
        IconButton(
          style: secondary,
          tooltip: 'Skip',
          onPressed: viewModel.skip,
          icon: const Icon(Icons.skip_next_outlined),
        ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      message,
      textAlign: TextAlign.center,
      style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
