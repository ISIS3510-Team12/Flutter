import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/pace_warning_card.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/task_filter_card.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/task_card.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  String selectedFilter = 'In progress';

  String _getDueText(DateTime deadline) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(deadline.year, deadline.month, deadline.day);

    final difference = dueDate.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue';
    }

    if (difference == 0) {
      return 'Due today';
    }

    if (difference == 1) {
      return 'Due tomorrow';
    }

    return 'Due in $difference days';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectState = ref.watch(
      projectDetailViewModelProvider(widget.projectId),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          onPressed: () => context.pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text('Project detail', style: theme.textTheme.titleMedium),
      ),
      body: projectState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load the project. Please try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(
                    projectDetailViewModelProvider(widget.projectId),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (projectStateData) {
          final project = projectStateData.project;
          final tasks = projectStateData.tasks;

          final filteredTasks = tasks.where((task) {
            switch (selectedFilter) {
              case 'In progress':
                return task.status == TaskStatus.inProgress;
              case 'Upcoming':
                return task.status == TaskStatus.pending;
              case 'Completed':
                return task.status == TaskStatus.done;
              default:
                return true;
            }
          }).toList();

          final deadline = DateFormat('EEEE, MMMM d').format(project.deadline);

          final completedTasks = tasks
              .where((task) => task.status == TaskStatus.done)
              .length;

          final remainingTasks = tasks.length - completedTasks;

          final daysRemaining = project.deadline
              .difference(DateTime.now())
              .inDays;

          final currentPace = daysRemaining > 0
              ? remainingTasks / daysRemaining
              : remainingTasks.toDouble();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  project.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),

                _InfoSection(
                  title: 'Progress',
                  subtitle: '$completedTasks of ${tasks.length} tasks complete',
                ),
                const SizedBox(height: 12),
                _ProgressBar(completed: completedTasks, total: tasks.length),
                const SizedBox(height: 16),

                _InfoSection(title: 'Deadline', subtitle: deadline),
                const SizedBox(height: 16),

                _InfoSection(
                  title: 'Current pace',
                  subtitle: '${currentPace.round()} tasks per day',
                ),
                const SizedBox(height: 16),

                PaceWarningCard(
                  completedTasks: completedTasks,
                  totalTasks: tasks.length,
                  deadline: project.deadline,
                ),

                const SizedBox(height: 24),

                Text('Tasks', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TaskFilter(
                          text: 'In progress',
                          selected: selectedFilter == 'In progress',
                          onTap: () {
                            setState(() {
                              selectedFilter = 'In progress';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: TaskFilter(
                          text: 'Upcoming',
                          selected: selectedFilter == 'Upcoming',
                          onTap: () {
                            setState(() {
                              selectedFilter = 'Upcoming';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: TaskFilter(
                          text: 'Completed',
                          selected: selectedFilter == 'Completed',
                          onTap: () {
                            setState(() {
                              selectedFilter = 'Completed';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                if (filteredTasks.isEmpty)
                  const ProjectTaskCard(
                    title: 'No tasks',
                    assigneeName: 'There are no tasks for this filter.',
                  )
                else
                  ...filteredTasks.map(
                    (task) => ProjectTaskCard(
                      title: task.title,
                      assigneeName: task.assigneeName.isEmpty
                          ? null
                          : task.assigneeName,
                      dueText: _getDueText(task.deadline),
                      assigneeInitial: task.assigneeInitial,
                      onTap: () {
                        context.push(Routes.taskPath(task.id));
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.onPrimaryContainer,
        foregroundColor: theme.colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => context.push(Routes.createTask),
        icon: const Icon(Symbols.stars, fill: 1),
        label: Text('Add task', style: theme.textTheme.labelLarge),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final remaining = total - completed;

    final colorScheme = Theme.of(context).colorScheme;
    final purple = colorScheme.primary;
    final teal = colorScheme.secondary;
    final trackColor = colorScheme.surfaceContainerHighest;

    Widget segment(Color color) => ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(height: 6, color: color),
    );

    if (total == 0) {
      return segment(trackColor);
    }

    return Row(
      children: [
        if (completed > 0) Expanded(flex: completed, child: segment(purple)),
        if (completed > 0 && remaining > 0) const SizedBox(width: 4),
        if (remaining > 0) Expanded(flex: remaining, child: segment(teal)),
      ],
    );
  }
}
