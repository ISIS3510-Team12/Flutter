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
  });

  final VoidCallback onMarkComplete;
  final VoidCallback onEditTask;
  final VoidCallback onDeleteTask;
  final VoidCallback onAskForHelp;
  final VoidCallback onMarkStarted;

  @override
  State<TaskActionsFab> createState() => TaskActionsFabState();
}

class TaskActionsFabState extends State<TaskActionsFab> {
  bool _expanded = false;

  void _run(VoidCallback action) {
    setState(() => _expanded = false);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!_expanded) {
      return FloatingActionButton.extended(
        backgroundColor: scheme.onPrimaryContainer,
        foregroundColor: scheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => setState(() => _expanded = true),
        icon: const Icon(Symbols.stars, fill: 1),
        label: Text('Task Actions', style: theme.textTheme.labelLarge),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _ActionPill(
          icon: Symbols.check,
          label: 'Mark as complete',
          onPressed: () => _run(widget.onMarkComplete),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.edit,
          label: 'Edit Task',
          onPressed: () => _run(widget.onEditTask),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.delete,
          label: 'Delete Task',
          onPressed: () => _run(widget.onDeleteTask),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.chat,
          label: 'Ask for help',
          onPressed: () => _run(widget.onAskForHelp),
        ),
        const SizedBox(height: 4),
        _ActionPill(
          icon: Symbols.star,
          label: 'Mark as started',
          onPressed: () => _run(widget.onMarkStarted),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          onPressed: () => setState(() => _expanded = false),
          child: const Icon(Symbols.close, size: 20),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(28);
    return Material(
      color: scheme.onPrimaryContainer,
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
              Icon(icon, size: 24, color: scheme.primaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.primaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
