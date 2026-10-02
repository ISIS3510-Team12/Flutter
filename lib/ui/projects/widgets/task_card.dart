import 'package:flutter/material.dart';

class ProjectTaskCard extends StatelessWidget {
  const ProjectTaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.assigneeInitial,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String? assigneeInitial;
  final VoidCallback? onTap;

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
        onTap: onTap,
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
