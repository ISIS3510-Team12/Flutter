import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_type_label.dart';

class TaskTypeDropdown extends StatelessWidget {
  const TaskTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final TaskType value;
  final ValueChanged<TaskType> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<TaskType>(
      initialValue: value,
      style: taskMenuTextStyle(theme),
      icon: const Icon(Symbols.arrow_right, size: 20),
      decoration: taskMenuDecoration(theme),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
      items: TaskType.values
          .map(
            (type) =>
                DropdownMenuItem(value: type, child: Text(taskTypeLabel(type))),
          )
          .toList(),
    );
  }
}

class TaskFlagSwitches extends StatelessWidget {
  const TaskFlagSwitches({
    super.key,
    required this.isPriority,
    required this.needsHelp,
    required this.onPriorityChanged,
    required this.onNeedsHelpChanged,
  });

  final bool isPriority;
  final bool needsHelp;
  final ValueChanged<bool> onPriorityChanged;
  final ValueChanged<bool> onNeedsHelpChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SwitchRow(
          label: 'IS PRIORITY',
          value: isPriority,
          onChanged: onPriorityChanged,
        ),
        _SwitchRow(
          label: 'NEEDS HELP',
          value: needsHelp,
          onChanged: onNeedsHelpChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 130, child: TaskFieldLabel(label)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
