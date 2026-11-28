import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/pomodoro/pomodoro.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/widgets/duration_input_dialog.dart';
import 'package:team12_flutter_juggle/ui/tools/pomodoro/widgets/timer_dial.dart';

class DurationSettingsCard extends StatelessWidget {
  const DurationSettingsCard({
    super.key,
    required this.settings,
    required this.enabled,
    required this.onFocusChanged,
    required this.onBreakChanged,
  });

  final PomodoroSettings settings;
  final bool enabled;
  final ValueChanged<int> onFocusChanged;
  final ValueChanged<int> onBreakChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _DurationRow(
            label: 'Focus',
            minutes: settings.focusMinutes,
            min: PomodoroSettings.minFocusMinutes,
            max: PomodoroSettings.maxFocusMinutes,
            enabled: enabled,
            onChanged: onFocusChanged,
          ),
          Divider(height: 1, color: colors.outlineVariant),
          _DurationRow(
            label: 'Break',
            minutes: settings.breakMinutes,
            min: PomodoroSettings.minBreakMinutes,
            max: PomodoroSettings.maxBreakMinutes,
            enabled: enabled,
            onChanged: onBreakChanged,
          ),
        ],
      ),
    );
  }
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.label,
    required this.minutes,
    required this.min,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final int minutes;
  final int min;
  final int max;
  final bool enabled;
  final ValueChanged<int> onChanged;

  Future<void> _typeMinutes(BuildContext context) async {
    final typed = await showDialog<int>(
      context: context,
      builder: (_) => DurationInputDialog(
        label: label,
        minutes: minutes,
        min: min,
        max: max,
      ),
    );
    if (typed != null) onChanged(typed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final style = theme.textTheme.titleSmall?.copyWith(color: colors.primary);
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: pomodoroTint(colors),
      foregroundColor: colors.primary,
      minimumSize: const Size.square(28),
      fixedSize: const Size.square(28),
      padding: EdgeInsets.zero,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        IconButton(
          style: buttonStyle,
          iconSize: 18,
          tooltip: 'Shorter ${label.toLowerCase()}',
          onPressed: enabled && minutes > min
              ? () => onChanged(minutes - 1)
              : null,
          icon: const Icon(Icons.remove),
        ),
        Tooltip(
          message: 'Type ${label.toLowerCase()} minutes',
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(84, 48),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            onPressed: enabled ? () => _typeMinutes(context) : null,
            child: Text(
              '$minutes min',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
        IconButton(
          style: buttonStyle,
          iconSize: 18,
          tooltip: 'Longer ${label.toLowerCase()}',
          onPressed: enabled && minutes < max
              ? () => onChanged(minutes + 1)
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
