import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final projectState = ref.watch(
      projectDetailViewModelProvider(widget.projectId),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Project'),
      ),
      body: projectState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load project.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (projectStateData) {
          final project = projectStateData.project;
          final tasks = projectStateData.tasks;

          final filteredTasks = tasks.where((task) {
            switch (selectedFilter) {
              case 'Pending':
                return task.status != TaskStatus.done;
              case 'Completed':
                return task.status == TaskStatus.done;
              default:
                return true;
            }
          }).toList();

          final deadline =
              '${project.deadline.day}/${project.deadline.month}/${project.deadline.year}';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Deadline: $deadline',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                PaceWarningCard(
                  completedTasks: tasks
                      .where((task) => task.status == TaskStatus.done)
                      .length,
                  totalTasks: tasks.length,
                  deadline: project.deadline,
                ),

                const SizedBox(height: 24),

                Text(
                  'Tasks',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TaskFilter(
                        text: 'All',
                        selected: selectedFilter == 'All',
                        onTap: () {
                          setState(() {
                            selectedFilter = 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TaskFilter(
                        text: 'Pending',
                        selected: selectedFilter == 'Pending',
                        onTap: () {
                          setState(() {
                            selectedFilter = 'Pending';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
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

                const SizedBox(height: 12),

                if (filteredTasks.isEmpty)
                  const ProjectTaskCard(
                    title: 'No tasks',
                    subtitle: 'There are no tasks for this filter.',
                  )
                else
                  ...filteredTasks.map(
                    (task) => ProjectTaskCard(
                      title: task.title,
                      subtitle: task.assigneeName.isEmpty
                          ? 'Unassigned'
                          : 'Assigned: ${task.assigneeName}',
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
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
