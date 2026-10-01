import 'package:flutter/material.dart';

class TaskFilter extends StatelessWidget {
  final String text;
  final bool selected;

  const TaskFilter({
    super.key,
    required this.text,
    required this.selected,
  });

  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.secondary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: selected
              ? theme.colorScheme.onSecondary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


