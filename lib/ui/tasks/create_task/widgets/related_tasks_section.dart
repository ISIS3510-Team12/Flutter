import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';

class RelatedTasksSection extends StatelessWidget {
  const RelatedTasksSection({
    super.key,
    required this.tasks,
    required this.selectedIds,
    required this.onQueryChanged,
    required this.onToggle,
  });

  final List<Task> tasks;
  final Set<String> selectedIds;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('RELATED TASKS', style: theme.textTheme.labelMedium),
            const Spacer(),
            if (selectedIds.isNotEmpty)
              Text(
                '${selectedIds.length} selected',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Search for a task...',
            hintStyle: taskHintStyle(theme),
            suffixIcon: const Icon(Symbols.search),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHigh,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        _RelatedTasksList(
          tasks: tasks,
          selectedIds: selectedIds,
          onToggle: onToggle,
        ),
      ],
    );
  }
}

class _RelatedTasksList extends StatelessWidget {
  const _RelatedTasksList({
    required this.tasks,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Task> tasks;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  static const _itemHeight = 72.0;
  static const _maxVisibleItems = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No tasks found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(
        maxHeight: _itemHeight * _maxVisibleItems,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final candidate = tasks[index];
            return CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  candidate.assigneeInitial,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              title: Text(
                candidate.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Due date: ${deadlineDate(candidate.deadline)}'),
              value: selectedIds.contains(candidate.id),
              onChanged: (_) => onToggle(candidate.id),
            );
          },
        ),
      ),
    );
  }
}
