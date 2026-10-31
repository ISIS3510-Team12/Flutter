import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_names.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_session_mixin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_dialog.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_mixin.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/domain/models/user/user.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_edit_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/groups/view_models/group_users_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';

class GroupEditScreen extends ConsumerStatefulWidget {
  const GroupEditScreen({
    super.key,
    required this.groupId,
  });

  final int groupId;

  @override
  ConsumerState<GroupEditScreen> createState() =>
      _GroupEditScreenState();
}

class _GroupEditScreenState extends ConsumerState<GroupEditScreen> {
  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(
      groupEditViewModelProvider(widget.groupId),
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
                        groupEditViewModelProvider(widget.groupId),
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
            groupId: widget.groupId,
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

class _GroupEditFormState extends ConsumerState<_GroupEditForm>
    with ShakeResetMixin<_GroupEditForm>, FeatureSessionMixin<_GroupEditForm> {
  @override
  String get featureName => FeatureNames.editGroup;

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController searchController;

  final _formKey = GlobalKey<FormState>();
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

    startShakeDetector(_resetForm);
  }

  @override
  void dispose() {
    stopShakeDetector();
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _resetForm() async {
    if (!mounted) return;

    if (ref.read(
      groupEditViewModelProvider(widget.groupId),
    ).isLoading) {
      return;
    }

    await runGuardedReset(() async {
      final shouldReset = await showShakeDiscardDialog(
        context: context,
        entity: 'group',
      );

      if (!mounted || shouldReset != true) return;

      nameController.text = widget.group.name;
      descriptionController.text = widget.group.description;
      searchController.clear();

      selectedUserIds
        ..clear()
        ..addAll(
          widget.group.members.map((member) => member.id),
        );

      _formKey.currentState?.reset();

      setState(() {
        searchQuery = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes discarded.'),
        ),
      );
    });
  }

  Future<void> _updateGroup(List<User> users) async {
    if (!_formKey.currentState!.validate()) return;

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
      markFeatureCompleted();
      context.pop(true);
    } else {
      final isOnline = ref.read(isOnlineProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOnline
                ? 'Could not update the group. Please try again.'
                : 'No internet connection. Please reconnect and try again.',
          ),
        ),
      );
    }
  }

  List<User> filteredUsers(List<User> users) {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) return users;

    return users.where((user) {
      final fullName =
          '${user.firstName} ${user.lastName}'.toLowerCase();
      final email = user.email.toLowerCase();

      return fullName.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(
      groupEditViewModelProvider(widget.groupId),
    );

    final usersState = ref.watch(groupUsersViewModelProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final isLoading = groupState.isLoading;

    final users = usersState.asData?.value ?? <User>[];
    final directoryAvailable = usersState.asData != null;
    final availableUsers = filteredUsers(users);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOnline) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: Theme.of(context)
                          .colorScheme
                          .onErrorContainer,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You are offline. Reconnect to save group changes.',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            _buildGroupNameField(context),
            const SizedBox(height: 20),
            _buildDescriptionField(context),
            const SizedBox(height: 28),
            _buildEditPeopleSection(
              context,
              availableUsers,
              directoryAvailable: directoryAvailable,
            ),
            if (!directoryAvailable && usersState.hasError && isOnline) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {
                    ref.invalidate(groupUsersViewModelProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry loading users'),
                ),
              ),
            ],
            const SizedBox(height: 28),
            _buildButtons(
              context,
              isLoading,
              users,
              isOnline,
            ),
          ],
        ),
      ),
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
        TextFormField(
          controller: nameController,
          validator: Validators.name,
          inputFormatters: Validators.titleTextInputFormatters,
          maxLength: Validators.maxNameLength,
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
          inputFormatters: Validators.descriptionTextInputFormatters,
          maxLines: 2,
          maxLength: Validators.maxDescriptionLength,
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
    List<User> users, {
    required bool directoryAvailable,
  }) {
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
        if (directoryAvailable) ...[
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
                child: Text('No users found.'),
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
                  backgroundColor:
                      theme.colorScheme.secondaryContainer,
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : 'A',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
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
        ] else ...[
          const Text(
            'The user directory is unavailable. You can still edit the group name and description. Current members are shown below.',
          ),
          const SizedBox(height: 12),
          ...widget.group.members.map(
            (member) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: Text(member.name),
              subtitle: const Text('Current member'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildButtons(
    BuildContext context,
    bool isLoading,
    List<User> users,
    bool isOnline,
  ) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: (isLoading || !isOnline)
                ? null
                : () => _updateGroup(users),
            icon: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  )
                : const Icon(Icons.check),
            label: Text(
              isLoading
                  ? 'Editing...'
                  : (!isOnline ? 'Offline' : 'Edit Group'),
            ),
            style: FilledButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              foregroundColor:
                  Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isLoading ? null : () => context.pop(),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
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
