import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({
    super.key,
  });

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
              'Sprint 2 Planning',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Coordinate the team's upcoming sprint work",
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
              '6 of 10 tasks complete',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(width: 3),

                Expanded(
                  flex: 4,
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
              'Friday, September 18',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

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
                  child: _TaskFilter(
                    text: 'In progress',
                    selected: true,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: _TaskFilter(
                    text: 'Upcoming',
                    selected: false,
                  ),
                ),

                const SizedBox(width: 4),

                Expanded(
                  child: _TaskFilter(
                    text: 'Completed',
                    selected: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tasks
            _TaskCard(
              title: 'Finish the sprint 2 Figma',
              subtitle: 'Diego - Due tomorrow',
            ),

            _TaskCard(
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


class _TaskFilter extends StatelessWidget {
  final String text;
  final bool selected;

  const _TaskFilter({
    required this.text,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.secondary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: selected
              ? theme.colorScheme.onSecondary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}


class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TaskCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),

        leading: CircleAvatar(
          radius: 20,
          backgroundColor: theme.colorScheme.secondary,
          child: Text(
            'D',
            style: TextStyle(
              color: theme.colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(subtitle),
      ),
    );
  }
}