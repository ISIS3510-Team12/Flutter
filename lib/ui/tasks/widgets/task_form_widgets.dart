import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';

TextStyle? taskHintStyle(ThemeData theme) {
  return theme.textTheme.bodyLarge?.copyWith(
    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
  );
}

TextStyle? taskMenuTextStyle(ThemeData theme) {
  return theme.textTheme.bodyLarge?.copyWith(
    color: theme.colorScheme.onSurface,
  );
}

InputDecoration taskMenuDecoration(ThemeData theme) {
  return InputDecoration(
    prefixIcon: const Icon(Symbols.stars, size: 20),
    filled: true,
    fillColor: theme.colorScheme.surfaceContainerLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration taskInactiveDecoration(ThemeData theme) {
  return InputDecoration(
    prefixIcon: const Icon(Symbols.stars, size: 20),
    filled: true,
    fillColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: BorderSide.none,
    ),
  );
}

InputDecoration taskTimingDecoration(
  ThemeData theme, {
  required String label,
  required String hint,
  required IconData icon,
  String? helper,
}) {
  final accent = theme.colorScheme.onPrimaryContainer;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: accent, width: 3),
  );
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: accent),
    floatingLabelStyle: TextStyle(color: accent),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: hint,
    hintStyle: taskHintStyle(theme),
    helperText: helper,
    suffixIcon: Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon),
      ),
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  );
}

class TaskFieldLabel extends StatelessWidget {
  const TaskFieldLabel(
    this.text, {
    super.key,
    this.required = false,
    this.bold = false,
  });

  final String text;
  final bool required;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: bold ? AppFontWeight.bold : AppFontWeight.regular,
      color: scheme.onSurfaceVariant,
    );
    return Text.rich(
      TextSpan(
        text: text,
        style: style,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: style?.copyWith(color: scheme.error),
            ),
        ],
      ),
    );
  }
}

class TaskMemberChip extends StatelessWidget {
  const TaskMemberChip({
    super.key,
    required this.name,
    required this.initial,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String initial;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: selected
                ? scheme.primaryContainer
                : scheme.onPrimaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: selected
                    ? scheme.onPrimaryContainer
                    : scheme.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            color: scheme.surfaceContainerLow,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskMembersSelector extends StatelessWidget {
  const TaskMembersSelector({
    super.key,
    required this.members,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<TaskMember> members;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final member in members)
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: TaskMemberChip(
                  name: member.name,
                  initial: member.initial,
                  selected: selectedIds.contains(member.id),
                  onTap: () => onToggle(member.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
