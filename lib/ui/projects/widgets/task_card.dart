import 'package:flutter/material.dart';

class ProjectTaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? assigneeInitial;

  const ProjectTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.assigneeInitial,
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
            assigneeInitial ?? '?',
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