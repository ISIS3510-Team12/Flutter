import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';


import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/groups_view_model.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/groups_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/widgets/group_card.dart';
import 'package:go_router/go_router.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(groupsViewModelProvider);
    final groupRepository = ref.watch(groupRepositoryProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          _buildSearchBar(context, viewModel),
          Expanded(
            child: _buildGroupsContent(
              context,
              viewModel,
              groupRepository,
            ),
          ),
          _buildCreateGroupButton(
            context,
            viewModel,
            groupRepository,
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    GroupsViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SizedBox(
        height: 60,
        child: TextField(
          onChanged: viewModel.onQueryChange,
          decoration: InputDecoration(
            hintText: 'Search group',
            suffixIcon: const Icon(Icons.search),
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupsContent(
    BuildContext context,
    GroupsViewModel viewModel,
    GroupRepository groupRepository,
  ) {
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load groups.'),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: viewModel.loadGroups,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.filteredGroups.isEmpty) {
      return const Center(
        child: Text('No groups found.'),
      );
    }

    return ListView.builder(
      itemCount: viewModel.filteredGroups.length,
      itemBuilder: (context, index) {
        final group = viewModel.filteredGroups[index];

        return GroupCard(
          group: group,
          onClick: () {
            context.push(
              Routes.groupDetailPath(group.id),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateGroupButton(
    BuildContext context,
    GroupsViewModel viewModel,
    GroupRepository groupRepository,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 190,
          height: 50,
          child: FilledButton.icon(
            onPressed: () async {
              final groupCreated = await context.push<bool>(
                Routes.createGroup,
              );

              if (!context.mounted) return;

              if (groupCreated == true) {
                await viewModel.loadGroups();
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Group'),
            style: FilledButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}