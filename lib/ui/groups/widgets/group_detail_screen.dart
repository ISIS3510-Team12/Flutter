import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_detail_view_model_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';

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

    return Scaffold(
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
                  'No se pudo cargar el grupo.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(
                      groupDetailViewModelProvider(groupId),
                    );
                  },
                  child: const Text('Intentar nuevamente'),
                ),
              ],
            ),
          ),
        ),
        data: (state) {
          return _buildContent(
            context,
            ref,
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
        backgroundColor:
            Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor:
            Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Create project'),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    Group group,
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
          const SizedBox(height: 4),
          Text(
            group.description,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Text(
            'Members',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMembers(context, group),
          const SizedBox(height: 32),
          Text(
            'Related projects',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
    Group group,
  ) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: group.users.map<Widget>((user) {
        final initial = user.firstName.isNotEmpty
            ? user.firstName[0].toUpperCase()
            : 'A';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.firstName,
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
                  color: theme.colorScheme.onPrimaryContainer,
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
