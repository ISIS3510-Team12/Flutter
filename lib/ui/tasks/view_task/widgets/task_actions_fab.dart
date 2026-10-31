import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class TaskActionsFab extends StatefulWidget {
  const TaskActionsFab({
    super.key,
    required this.onMarkComplete,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.onAskForHelp,
    required this.onMarkStarted,
    required this.enabled,
    required this.onUnavailable,
  });

  final VoidCallback onMarkComplete;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;
  final VoidCallback onAskForHelp;
  final VoidCallback onMarkStarted;
  final bool enabled;
  final ValueChanged<String> onUnavailable;

  @override
  State<TaskActionsFab> createState() => TaskActionsFabState();
}

class TaskActionsFabState extends State<TaskActionsFab> {
  bool _expanded = false;

  void _run(VoidCallback action, String offlineAction) {
    if (!widget.enabled) {
      widget.onUnavailable(offlineAction);
      return;
    }
    setState(() => _expanded = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final noInk = theme.copyWith(
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );

    if (!_expanded) {
      return Theme(
        data: noInk,
        child: FloatingActionButton.extended(
          heroTag: null,
          backgroundColor: scheme.onPrimaryContainer,
          foregroundColor: scheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => setState(() => _expanded = true),
          icon: const Icon(Symbols.stars, fill: 1),
          label: Text(
            'Task Actions',
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.primaryContainer,
            ),
          ),
        ),
      );
    }

    return Theme(
      data: noInk,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ActionPill(
            icon: Symbols.check,
            label: 'Mark as complete',
            enabled: widget.enabled,
            onPressed: () => _run(widget.onMarkComplete, 'complete this task'),
          ),
          const SizedBox(height: 4),
          _ActionPill(
            icon: Symbols.edit,
            label: 'Edit Task',
            enabled: widget.enabled,
            onPressed: () => _run(widget.onEditTask, 'edit this task'),
          ),
          const SizedBox(height: 4),
          _ActionPill(
            icon: Symbols.delete,
            label: 'Delete Task',
            enabled: widget.enabled,
            onPressed: () => _run(widget.onDeleteTask, 'delete this task'),
          ),
          const SizedBox(height: 4),
          _ActionPill(
            icon: Symbols.chat,
            label: 'Ask for help',
            enabled: widget.enabled,
            onPressed: () =>
                _run(widget.onAskForHelp, 'ask for help on this task'),
          ),
          const SizedBox(height: 4),
          _ActionPill(
            icon: Symbols.star,
            label: 'Mark as started',
            enabled: widget.enabled,
            onPressed: () => _run(widget.onMarkStarted, 'start this task'),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: null,
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.onPrimaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            onPressed: () => setState(() => _expanded = false),
            child: const Icon(Symbols.close, size: 20),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(28);
    final background = enabled
        ? scheme.onPrimaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = enabled
        ? scheme.primaryContainer
        : scheme.onSurface.withValues(alpha: 0.38);
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: background,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: foreground),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
