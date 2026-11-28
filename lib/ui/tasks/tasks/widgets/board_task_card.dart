import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

class DraggableBoardTaskCard extends StatelessWidget {
  const DraggableBoardTaskCard({
    super.key,
    required this.task,
    required this.locked,
    required this.onTap,
    required this.onMenu,
    required this.onLockedLongPress,
    required this.onDragUpdate,
  });

  final Task task;
  final bool locked;
  final VoidCallback onTap;
  final VoidCallback onMenu;
  final VoidCallback onLockedLongPress;
  final DragUpdateCallback onDragUpdate;

  @override
  Widget build(BuildContext context) {
    final card = BoardTaskCard(
      task: task,
      locked: locked,
      onTap: onTap,
      onMenu: onMenu,
      onLongPress: locked ? onLockedLongPress : null,
    );
    if (locked) return card;
    return LayoutBuilder(
      builder: (context, constraints) => LongPressDraggable<Task>(
        data: task,
        onDragUpdate: onDragUpdate,
        feedback: Transform.rotate(
          angle: 0.04,
          child: SizedBox(
            width: constraints.maxWidth,
            child: BoardTaskCard(task: task, locked: false, elevation: 6),
          ),
        ),
        childWhenDragging: Opacity(opacity: 0.4, child: card),
        child: card,
      ),
    );
  }
}

class BoardTaskCard extends StatelessWidget {
  const BoardTaskCard({
    super.key,
    required this.task,
    required this.locked,
    this.onTap,
    this.onMenu,
    this.onLongPress,
    this.elevation = 0,
  });

  final Task task;
  final bool locked;
  final VoidCallback? onTap;
  final VoidCallback? onMenu;
  final VoidCallback? onLongPress;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final updatedAt = task.updatedAt;
    return Material(
      color: scheme.surfaceContainerLowest,
      elevation: elevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TaskBadges(task: task),
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AssigneeLine(task: task),
                    if (updatedAt != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        updatedAgo(updatedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: locked ? 'Reconnect to move this task' : 'Move to',
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                onPressed: onMenu,
                icon: Icon(locked ? Symbols.lock : Symbols.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskBadges extends StatelessWidget {
  const _TaskBadges({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (!task.isPriority && !task.needsHelp) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (task.isPriority)
            _Badge(
              label: 'Priority',
              background: scheme.tertiary,
              foreground: scheme.onTertiary,
            ),
          if (task.needsHelp)
            _Badge(
              label: 'Needs help',
              background: scheme.primaryFixed,
              foreground: scheme.onPrimaryFixedVariant,
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground),
      ),
    );
  }
}

class _AssigneeLine extends StatelessWidget {
  const _AssigneeLine({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = task.assigneeName.isEmpty ? 'Unassigned' : task.assigneeName;
    final initial = task.assigneeInitial.isEmpty ? '?' : task.assigneeInitial;
    return Row(
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: scheme.secondaryContainer,
          child: Text(
            initial,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$name • ${deadlineDay(task.deadline)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
