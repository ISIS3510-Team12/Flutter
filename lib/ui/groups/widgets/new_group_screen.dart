import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:team12_flutter_juggle/domain/models/user/user.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_users_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/new_group_view_model_provider.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({
    super.key,
  });

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final Set<String> selectedUserIds = {};
  String searchQuery = '';

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    searchController.dispose();
    super.dispose();
  }

    
  Future<void> _createGroup() async {
    final success = await ref
        .read(newGroupViewModelProvider.notifier)
        .createGroup(
          name: nameController.text.trim(),
          description: classController.text.trim(),
          selectedUserIds: selectedUserIds.toList(),
        );

    if (!mounted) return;

    if (success) {
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create the group.'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(groupUsersViewModelProvider);
    final groupState = ref.watch(newGroupViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              context: context,
              label: 'Name',
              hintText: 'An amazing group',
              helperText: 'Give your group a name',
              controller: nameController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              label: 'Description',
              hintText: 'ISIS-3510 group',
              helperText: 'Enter the group description',
              controller: classController,
            ),
            const SizedBox(height: 28),
            Text(
              'Add People',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSearchField(context),
            const SizedBox(height: 12),
            _buildUsersContent(
              context,
              usersState,
            ),
            const SizedBox(height: 24),
            _buildActionButtons(
              context,
              groupState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersContent(
    BuildContext context,
    AsyncValue<List<User>> usersState,
  ) {
    return usersState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) => Row(
        children: [
          const Expanded(
            child: Text(
              'Could not load users.',
            ),
          ),
          TextButton(
            onPressed: () {
              ref.invalidate(groupUsersViewModelProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (users) {
        final filteredUsers = _filteredUsers(users);

        if (filteredUsers.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'No users found.',
            ),
          );
        }

        return Column(
          children: [
            ...filteredUsers.map(
              (user) => _buildUserTile(
                context: context,
                user: user,
              ),
            ),
          ],
        );
      },
    );
  }

  List<User> _filteredUsers(List<User> users) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return users;
    }

    return users.where((user) {
      final fullName =
          '${user.firstName} ${user.lastName}'.toLowerCase();

      return fullName.contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required String hintText,
    required String helperText,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search for users...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
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
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  Widget _buildUserTile({
    required BuildContext context,
    required User user,
  }) {
    final theme = Theme.of(context);

    final name = '${user.firstName} ${user.lastName}'.trim();

    final initial = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initial,
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Checkbox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    bool isLoading,
  ) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading ? null : _createGroup,
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            icon: isLoading
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : const Icon(
                    Icons.check,
                    size: 20,
                  ),
            label: Text(
              isLoading ? 'Creating...' : 'Create Group',
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
            icon: const Icon(Icons.close, size: 20),
            label: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
