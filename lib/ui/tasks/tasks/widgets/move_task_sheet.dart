import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/board_status.dart';

Future<TaskStatus?> showMoveTaskSheet(BuildContext context, Task task) {
  return showModalBottomSheet<TaskStatus>(
    context: context,
    showDragHandle: true,
    builder: (_) => MoveTaskSheet(task: task),
  );
}

class MoveTaskSheet extends StatelessWidget {
  const MoveTaskSheet({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move to', style: theme.textTheme.headlineSmall),
            Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final status in TaskStatus.values)
              _MoveOption(
                status: status,
                current: status == task.status,
                onSelected: () => Navigator.of(context).pop(status),
              ),
          ],
        ),
      ),
    );
  }
}

class _MoveOption extends StatelessWidget {
  const _MoveOption({
    required this.status,
    required this.current,
    required this.onSelected,
  });

  final TaskStatus status;
  final bool current;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: current,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: current ? scheme.surfaceContainerHigh : null,
        onTap: current ? null : onSelected,
        leading: Icon(
          current ? Symbols.check_circle : Symbols.radio_button_unchecked,
          fill: current ? 1 : 0,
          color: current ? scheme.primaryContainer : scheme.onSurfaceVariant,
        ),
        title: Text(
          status.boardLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppFontWeight.bold,
            color: current ? scheme.primaryContainer : scheme.onSurface,
          ),
        ),
        trailing: current
            ? Text('Current', style: theme.textTheme.labelSmall)
            : null,
      ),
    );
  }
}
