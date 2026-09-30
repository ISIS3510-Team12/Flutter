import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/view_models/all_tasks_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/view_models/all_tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/view_task_screen.dart';

class AllTasksScreen extends ConsumerWidget {
  const AllTasksScreen({super.key});

  void _openTask(BuildContext context, String taskId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ViewTaskScreen(taskId: taskId)));
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Urgent',
                    selected: data.filter == TaskFilter.urgent,
                    onTap: () => ref
                        .read(allTasksViewModelProvider.notifier)
                        .updateFilter(TaskFilter.urgent),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Due Soon',
                    selected: data.filter == TaskFilter.dueSoon,
                    onTap: () => ref
                        .read(allTasksViewModelProvider.notifier)
                        .updateFilter(TaskFilter.dueSoon),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Assigned to me',
                    selected: data.filter == TaskFilter.assignedToMe,
                    onTap: () => ref
                        .read(allTasksViewModelProvider.notifier)
                        .updateFilter(TaskFilter.assignedToMe),
                  ),
                ],
              ),
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

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
