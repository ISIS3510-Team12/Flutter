import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/groups_view_model.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/groups_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/widgets/group_card.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsState = ref.watch(groupsViewModelProvider);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          _buildSearchBar(context, ref),
          Expanded(child: _buildGroupsContent(context, groupsState, ref)),
        ],
      ),
      floatingActionButton: _buildCreateGroupButton(context, ref),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SizedBox(
        height: 60,
        child: TextField(
          onChanged: (query) {
            ref
                .read(groupsViewModelProvider.notifier)
                .onQueryChange(query);
          },
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
    AsyncValue<GroupsState> groupsState,
    WidgetRef ref,
  ) {
    return groupsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load groups.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(groupsViewModelProvider);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (state) {
        final groups = state.filteredGroups;

        if (groups.isEmpty) {
          return const Center(
            child: Text('No groups found.'),
          );
        }

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];

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
      },
    );
  }

  Widget _buildCreateGroupButton(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () async {
        final groupCreated = await context.push<bool>(Routes.createGroup);

        if (!context.mounted) return;

        if (groupCreated == true) {
          ref.invalidate(groupsViewModelProvider);
        }
      },
      backgroundColor: colorScheme.primaryFixed,
      foregroundColor: colorScheme.onPrimaryFixed,
      icon: const Icon(Symbols.add_circle),
      label: const Text('Create group'),
    );
  }
}
