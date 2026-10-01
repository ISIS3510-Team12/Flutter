import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/task_card.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/pace_warning_card.dart';
import 'package:team12_flutter_juggle/ui/projects/widgets/task_filter_card.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final int totalTasks = 10;
  final int completedTasks = 6;
  final DateTime projectStartDate = DateTime(2026, 9, 1);
  
  double get completedTasksPerDay {
    final daysElapsed =
        DateTime.now().difference(projectStartDate).inHours / 24;

    if (daysElapsed <= 0) {
      return completedTasks.toDouble();
    }

    return completedTasks / daysElapsed;
  }

  bool get showPaceWarning {
    final remainingTasks = totalTasks - completedTasks;

    if (remainingTasks <= 0) {
      return false;
    }

    if (completedTasksPerDay <= 0) {
      return true;
    }

    final daysNeeded =
        remainingTasks / completedTasksPerDay;

    final daysAvailable =
        widget.project.deadline
            .difference(DateTime.now())
            .inHours /
        24;

    return daysNeeded > daysAvailable;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Project detail'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Project name
            Text(
              widget.project.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              widget.project.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            // Progress
            Text(
              'Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '$completedTasks of $totalTasks tasks complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            Row(
            children: [
              Expanded(
                flex: completedTasks,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                flex: totalTasks - completedTasks,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

            const SizedBox(height: 12),

            // Deadline
            Text(
              'Deadline',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '${widget.project.deadline.day}/${widget.project.deadline.month}/${widget.project.deadline.year}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            //Pace
            const SizedBox(height: 20),

            Text(
              'Current pace',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              '${completedTasksPerDay.toStringAsFixed(0)} completed tasks per day',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            
            if (showPaceWarning) ...[
              const SizedBox(height: 16),
              PaceWarningCard(),
            ],

            // Tasks
            Text(
              'Tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Task filters
            Row(
              children: [
                Expanded(
                  child: TaskFilter(
                    text: 'In progress',
                    selected: true,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: TaskFilter(
                    text: 'Upcoming',
                    selected: false,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: TaskFilter(
                    text: 'Completed',
                    selected: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tasks
            TaskCard(
              title: 'Finish the sprint 2 Figma',
              subtitle: 'Diego - Due tomorrow',
            ),

            TaskCard(
              title: 'Finish the sprint 2 Figma',
              subtitle: 'Diego - Due tomorrow',
            ),

            const SizedBox(height: 16),

            // Add task
            Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add Task'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    foregroundColor:
                        Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                  ),
                ),
              ),
              ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}