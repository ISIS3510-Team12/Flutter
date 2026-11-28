import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_view_mode_provider.dart';

class TasksViewToggle extends StatelessWidget {
  const TasksViewToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final TasksViewMode mode;
  final ValueChanged<TasksViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SegmentedButton<TasksViewMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: TasksViewMode.list, label: Text('List')),
          ButtonSegment(value: TasksViewMode.board, label: Text('Board')),
        ],
        selected: {mode},
        onSelectionChanged: (selection) => onChanged(selection.single),
        style: SegmentedButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHigh,
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimary,
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
