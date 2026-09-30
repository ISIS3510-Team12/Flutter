import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/tasks/all_tasks/widgets/all_tasks_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/widgets/create_task_screen.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/group_drawer.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/widgets/view_task_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  void _openCreateTask(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
  }

  void _openTask(BuildContext context, String taskId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ViewTaskScreen(taskId: taskId)));
  }

  void _openAllTasks(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AllTasksScreen()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(tasksViewModelProvider);
    return Scaffold(
      appBar: const CustomAppBar(),
      drawer: const GroupDrawer(),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primaryFixed,
        foregroundColor: theme.colorScheme.onPrimaryFixed,
        onPressed: () => _openCreateTask(context),
        icon: const Icon(Symbols.add),
        label: const Text('Create task'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (data) {
          const visibleCount = 3;
          final visibleMyTasks = data.myTasks.take(visibleCount).toList();
          final visibleGroupTasks = data.groupTasks.take(visibleCount).toList();
          final hasMoreTasks =
              data.myTasks.length > visibleCount ||
              data.groupTasks.length > visibleCount;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Text('Current group', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  Builder(
                    builder: (context) => TextButton.icon(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: const Icon(Symbols.edit, size: 18),
                      label: const Text('Edit Group'),
                    ),
                  ),
                ],
              ),
              Text(data.groupName, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => ref
                    .read(tasksViewModelProvider.notifier)
                    .updateQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search for a task...',
                  suffixIcon: const Icon(Symbols.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your pending tasks',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (final task in visibleMyTasks) ...[
                TaskCard(task: task, onTap: () => _openTask(context, task.id)),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Text(
                'Pending group tasks',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              for (final task in visibleGroupTasks) ...[
                TaskCard(task: task, onTap: () => _openTask(context, task.id)),
                const SizedBox(height: 12),
              ],
              if (hasMoreTasks)
                Center(
                  child: TextButton.icon(
                    onPressed: () => _openAllTasks(context),
                    icon: const Icon(Symbols.expand_more),
                    label: const Text('View all tasks'),
                  ),
                ),
              const SizedBox(height: 96),
            ],
          );
        },
      ),
    );
  }
}
