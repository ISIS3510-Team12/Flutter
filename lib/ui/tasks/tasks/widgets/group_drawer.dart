import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

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
          decoration: const InputDecoration(hintText: 'Group name'),
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
    if (name != null && name.trim().isNotEmpty) {
      ref.read(tasksViewModelProvider.notifier).createGroup(name.trim());
    }
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
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Your Groups', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              for (final group in data.groups)
                if (group == data.groupName)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        Text(
                          '${data.pendingCountFor(group)} pending tasks',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(group, style: theme.textTheme.bodyLarge),
                    onTap: () {
                      ref
                          .read(tasksViewModelProvider.notifier)
                          .switchGroup(group);
                      Navigator.of(context).pop();
                    },
                  ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Symbols.add_circle),
                title: Text('New Group', style: theme.textTheme.bodyLarge),
                onTap: () => _createGroup(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
