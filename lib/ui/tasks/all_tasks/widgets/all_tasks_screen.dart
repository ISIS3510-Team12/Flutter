import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/view_models/all_tasks_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/view_models/all_tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';

class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({super.key});

  void _openTask(BuildContext context, String taskId) {
    context.push(Routes.taskPath(taskId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(allTasksViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      bottomNavigationBar: const CustomNavigationBar(),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FilterGroup(
              selected: data.filter,
              onSelected: (filter) => ref
                  .read(allTasksViewModelProvider.notifier)
                  .updateFilter(filter),
            ),
            const SizedBox(height: 16),
            if (data.filteredTasks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    'No tasks here',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            for (final task in data.filteredTasks) ...[
              TaskCard(task: task, onTap: () => _openTask(context, task.id)),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

const _segmentGap = 2.0;
const _segmentHorizontalPadding = 12.0;
const _segmentLabels = {
  TaskFilter.urgent: 'Urgent',
  TaskFilter.dueSoon: 'Due Soon',
  TaskFilter.assignedToMe: 'Assigned to me',
};

TextStyle? _segmentTextStyle(BuildContext context, [Color? color]) {
  return Theme.of(context).textTheme.labelMedium?.copyWith(color: color);
}

class _FilterGroup extends StatelessWidget {
  const _FilterGroup({required this.selected, required this.onSelected});

  final TaskFilter selected;
  final ValueChanged<TaskFilter> onSelected;

  List<double> _widths(BuildContext context, double available) {
    const filters = TaskFilter.values;
    final style = _segmentTextStyle(context);
    final minWidths = [
      for (final filter in filters)
        (TextPainter(
              text: TextSpan(text: _segmentLabels[filter], style: style),
              maxLines: 1,
              textDirection: TextDirection.ltr,
              textScaler: MediaQuery.textScalerOf(context),
            )..layout()).width +
            _segmentHorizontalPadding * 2,
    ];
    var remaining = available - _segmentGap * (filters.length - 1);
    final widths = List<double?>.filled(filters.length, null);
    var free = filters.length;
    var changed = true;
    while (changed && free > 0) {
      changed = false;
      final share = remaining / free;
      for (var i = 0; i < filters.length; i++) {
        if (widths[i] == null && minWidths[i] > share) {
          widths[i] = minWidths[i];
          remaining -= minWidths[i];
          free--;
          changed = true;
        }
      }
    }
    final share = free > 0 ? remaining / free : 0.0;
    return [for (final w in widths) w ?? share];
  }

  @override
  Widget build(BuildContext context) {
    const filters = TaskFilter.values;
    return LayoutBuilder(
      builder: (context, constraints) {
        final widths = _widths(context, constraints.maxWidth);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < filters.length; i++) ...[
                if (i > 0) const SizedBox(width: _segmentGap),
                SizedBox(
                  width: widths[i],
                  child: _FilterSegment(
                    label: _segmentLabels[filters[i]]!,
                    selected: selected == filters[i],
                    isFirst: i == 0,
                    isLast: i == filters.length - 1,
                    onTap: () => onSelected(filters[i]),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.selected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const outer = Radius.circular(16);
    const inner = Radius.circular(4);
    final radius = BorderRadius.horizontal(
      left: isFirst ? outer : inner,
      right: isLast ? outer : inner,
    );
    return Material(
      color: selected
          ? theme.colorScheme.secondary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 32,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: _segmentHorizontalPadding,
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: _segmentTextStyle(
              context,
              selected
                  ? theme.colorScheme.onSecondary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
