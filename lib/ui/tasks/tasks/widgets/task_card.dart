import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskCardAvatar(task: task),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.needsHelp)
                    Text(
                      'Needs Help.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                  if (!task.isMine)
                    Text(task.assigneeName, style: theme.textTheme.bodySmall),
                  Text(
                    deadlineText(task.deadline),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCardAvatar extends StatelessWidget {
  const _TaskCardAvatar({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!task.isMine) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Text(
          task.assigneeInitial,
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
        ),
      );
    }

    if (task.isPriority) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.tertiaryContainer,
        child: Icon(
          Symbols.priority_high,
          color: theme.colorScheme.onTertiaryContainer,
        ),
      );
    }

    return CircleAvatar(
      backgroundColor: theme.colorScheme.primaryFixed,
      child: Icon(Symbols.check, color: theme.colorScheme.onPrimaryFixed),
    );
  }
}
