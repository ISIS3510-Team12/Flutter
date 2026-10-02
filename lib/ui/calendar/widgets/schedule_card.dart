import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.title,
    required this.task,
    required this.assignedTo,
    required this.timeInfo,
  });

  final String title;
  final String task;
  final String assignedTo;
  final String timeInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.secondary,
              child: Text(
                assignedTo.isNotEmpty ? assignedTo[0].toUpperCase() : '?',
                style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    task,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Assigned: $assignedTo',
                    style: theme.textTheme.bodySmall,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    timeInfo,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}