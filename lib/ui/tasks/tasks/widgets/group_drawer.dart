import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';

class GroupDrawer extends ConsumerWidget {
  const GroupDrawer({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Group'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Group name',
            hintStyle: taskHintStyle(Theme.of(context)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    try {
      await ref.read(tasksViewModelProvider.notifier).createGroup(name.trim());
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The group could not be created. Try another name.'),
          ),
        );
      }
    }
  }

  Widget _groupTile(
    BuildContext context,
    WidgetRef ref,
    TaskGroup group,
    bool selected,
  ) {
    final theme = Theme.of(context);
    if (selected) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                group.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            Text(
              '${group.pendingCount} pending tasks',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: AppFontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(group.name, style: theme.textTheme.bodyLarge),
      onTap: () {
        ref.read(tasksViewModelProvider.notifier).switchGroup(group);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(tasksViewModelProvider);
    return Drawer(
      child: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (data) {
            final personal = data.groups.where((group) => group.isPersonal);
            final others = data.groups.where((group) => !group.isPersonal);
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final group in personal) ...[
                  Text('Personal', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _groupTile(context, ref, group, group.id == data.group?.id),
                  const Divider(),
                ],
                Text('Your Groups', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                for (final group in others)
                  _groupTile(context, ref, group, group.id == data.group?.id),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.add_circle),
                  title: Text('New Group', style: theme.textTheme.bodyLarge),
                  onTap: () => _createGroup(context, ref),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
