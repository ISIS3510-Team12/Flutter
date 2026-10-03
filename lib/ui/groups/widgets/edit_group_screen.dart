import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_edit_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_users_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class GroupEditScreen extends ConsumerWidget {
  const GroupEditScreen({
    super.key,
    required this.groupId,
  });

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(
      groupEditViewModelProvider(groupId),
    );

    return ScreenLoadTracker(
      screen: ScreenNames.editGroup,
      state: groupState,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
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
                      groupEditViewModelProvider(groupId),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (group) => _GroupEditForm(
          group: group,
          groupId: groupId,
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    ),
    );
  }
}

class _GroupEditForm extends ConsumerStatefulWidget {
  const _GroupEditForm({
    required this.group,
    required this.groupId,
  });

  final TaskGroup group;
  final int groupId;

  @override
  ConsumerState<_GroupEditForm> createState() =>
      _GroupEditFormState();
}

class _GroupEditFormState extends ConsumerState<_GroupEditForm> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController searchController;

  final Set<String> selectedUserIds = {};
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.group.name,
    );

    descriptionController = TextEditingController(
      text: widget.group.description,
    );

    searchController = TextEditingController();

    selectedUserIds.addAll(
      widget.group.members.map((member) => member.id),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _updateGroup(
    List<User> users,
  ) async {
    final viewModel = ref.read(
      groupEditViewModelProvider(widget.groupId).notifier,
    );

    final originalUserIds = widget.group.members
        .map((member) => member.id)
        .toSet();

    final emailsToAdd = users
        .where(
          (user) =>
              selectedUserIds.contains(user.userId) &&
              !originalUserIds.contains(user.userId),
        )
        .map((user) => user.email)
        .toList();

    final userIdsToRemove = originalUserIds
        .where(
          (userId) => !selectedUserIds.contains(userId),
        )
        .toList();

    final success = await viewModel.updateGroup(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      emailsToAdd: emailsToAdd,
      userIdsToRemove: userIdsToRemove,
    );

    if (!mounted) return;

    if (success) {
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update the group. Please try again.',
          ),
        ),
      );
    }
  }

  List<User> filteredUsers(
    List<User> users,
  ) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      final fullName =
          '${user.firstName} ${user.lastName}'.toLowerCase();
      final email = user.email.toLowerCase();

      return fullName.contains(query) ||
          email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(
      groupEditViewModelProvider(widget.groupId),
    );

    final usersState = ref.watch(groupUsersViewModelProvider);

    final isLoading = groupState.isLoading;

    return usersState.when(
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
                'Could not load users.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref.invalidate(groupUsersViewModelProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (users) {
        final availableUsers = filteredUsers(users);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupNameField(context),
              const SizedBox(height: 20),
              _buildDescriptionField(context),
              const SizedBox(height: 28),
              _buildEditPeopleSection(
                context,
                availableUsers,
              ),
              const SizedBox(height: 28),
              _buildButtons(
                context,
                isLoading,
                users,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupNameField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter group name',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'This is the current name of the group',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Enter group description',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'This is the current description of the group',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEditPeopleSection(
    BuildContext context,
    List<User> users,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Edit People',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 14),
        SearchBar(
          controller: searchController,
          hintText: 'Search users',
          trailing: [
            if (searchQuery.isNotEmpty)
              IconButton(
                onPressed: () {
                  searchController.clear();

                  setState(() {
                    searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            const Icon(Icons.search),
          ],
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 14),
        if (users.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No users found.',
              ),
            ),
          )
        else
          ...users.map(
            (user) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: selectedUserIds.contains(user.userId),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedUserIds.add(user.userId);
                  } else {
                    selectedUserIds.remove(user.userId);
                  }
                });
              },
              secondary: CircleAvatar(
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .secondaryContainer,
                child: Text(
                  user.firstName.isNotEmpty
                      ? user.firstName[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                '${user.firstName} ${user.lastName}',
              ),
              subtitle: Text(user.email),
            ),
          ),
      ],
    );
  }

  Widget _buildButtons(
    BuildContext context,
    bool isLoading,
    List<User> users,
  ) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => _updateGroup(users),
            icon: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(
              isLoading ? 'Editing...' : 'Edit Group',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading
                ? null
                : () {
                    context.pop();
                  },
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
