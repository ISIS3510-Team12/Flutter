import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_member.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_detail_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(
      groupDetailViewModelProvider(groupId),
    );

    return ScreenLoadTracker(
    screen: ScreenNames.groupDetail,
    state: groupState,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Group detail'),
        actions: [
          IconButton(
            onPressed: () async {
              final updated = await context.push<bool>(
                Routes.editGroupPath(groupId),
              );

              if (!context.mounted) return;

              if (updated == true) {
                ref.invalidate(
                  groupDetailViewModelProvider(groupId),
                );
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: groupState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load the group.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(
                      groupDetailViewModelProvider(groupId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          return _buildContent(
            context,
            state.group,
            state.projects,
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
            Routes.createProjectPath(groupId),
          );

          if (!context.mounted) return;

          ref.invalidate(
            groupDetailViewModelProvider(groupId),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primaryFixed,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        icon: const Icon(Symbols.add_circle),
        label: const Text('Create project'),
      ),
    ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TaskGroup group,
    List<Project> projects,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Members',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMembers(
            context,
            group.members,
          ),
          const SizedBox(height: 32),
          Text(
            'Related projects',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty)
            const Text('No projects found.')
          else
            ...projects.map(
              (project) => _buildProjectCard(
                context,
                project,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembers(
    BuildContext context,
    List<TaskMember> members,
  ) {
    final theme = Theme.of(context);

    if (members.isEmpty) {
      return const Text('No members found.');
    }

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: members.map<Widget>((member) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor:
                  theme.colorScheme.primaryContainer,
              child: Text(
                member.initial,
                style: TextStyle(
                  color:
                      theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              member.name,
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    Project project,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(
            Routes.projectDetailPath(project.id),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.folder_outlined,
                  color:
                      theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style:
                          theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
