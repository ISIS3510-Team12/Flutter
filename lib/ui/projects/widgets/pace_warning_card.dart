import 'package:flutter/material.dart';

class PaceWarningCard extends StatelessWidget {
  const PaceWarningCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.deadline,
  });

  final int completedTasks;
  final int totalTasks;
  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress = totalTasks == 0
        ? 0.0
        : completedTasks / totalTasks;

    final remainingTasks = totalTasks - completedTasks;

    final now = DateTime.now();
    final daysRemaining = deadline.difference(now).inDays;

    final paceTooSlow =
        totalTasks > 0 &&
        remainingTasks > 0 &&
        daysRemaining >= 0 &&
        remainingTasks > daysRemaining;

    final progressPercentage = (progress * 100).round();

    return Card(
      elevation: 0,
      color: paceTooSlow
          ? theme.colorScheme.errorContainer
          : theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  paceTooSlow
                      ? Icons.warning_amber_rounded
                      : Icons.trending_up,
                  color: paceTooSlow
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    paceTooSlow ? 'Pace too slow' : 'Project progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: paceTooSlow
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$completedTasks of $totalTasks tasks completed '
              '($progressPercentage%)',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 10),
            Text(
              totalTasks == 0
                  ? 'There are no tasks in this project yet.'
                  : remainingTasks == 0
                      ? 'All tasks have been completed.'
                      : daysRemaining < 0
                          ? '$remainingTasks tasks are still incomplete.'
                          : '$remainingTasks tasks remaining • '
                              '$daysRemaining days until the deadline.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}