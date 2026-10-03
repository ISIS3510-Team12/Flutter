import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/themes/app_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/widgets/group_name_dialog.dart';

class GroupDrawer extends ConsumerWidget {
  const GroupDrawer({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const GroupNameDialog(),
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
        Scaffold.of(context).closeDrawer();
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Your Groups', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                for (final group in data.groups)
                  _groupTile(context, ref, group, group.id == data.group?.id),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Symbols.checklist_rtl),
                  title: Text('All tasks', style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    context.push(Routes.allTasks);
                  },
                ),
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
