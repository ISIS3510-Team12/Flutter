import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

class TaskChip extends StatelessWidget {
  const TaskChip({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: chipColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.info, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(color: chipColor),
          ),
        ],
      ),
    );
  }
}

String taskStatusLabel(TaskStatus status) {
  switch (status) {
    case TaskStatus.pending:
      return 'Pending';
    case TaskStatus.inProgress:
      return 'In progress';
    case TaskStatus.done:
      return 'Done';
  }
}
