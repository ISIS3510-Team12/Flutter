import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/viewmodels/group_edit_view_model.dart';

class GroupEditScreen extends StatefulWidget {
  const GroupEditScreen({
    super.key,
    required this.group,
    required this.groupRepository,
  });

  final Group group;
  final GroupRepository groupRepository;

  @override
  State<GroupEditScreen> createState() => _GroupEditScreenState();
}

class _GroupEditScreenState extends State<GroupEditScreen> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;

  final Set<String> selectedUserIds = {};

  late final GroupEditViewModel viewModel;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.group.name,
    );

    descriptionController = TextEditingController(
      text: widget.group.description,
    );

    selectedUserIds.addAll(
      widget.group.users.map((user) => user.userId),
    );

    viewModel = GroupEditViewModel(
      groupRepository: widget.groupRepository,
    );
  }


  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _updateGroup() async {
    final success = await viewModel.updateGroup(
      groupId: widget.group.id,
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      userIds: selectedUserIds.toList(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Error updating group',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupNameField(context),
            const SizedBox(height: 24),
            _buildDescriptionField(context),
            const SizedBox(height: 32),
            _buildEditPeopleSection(context),
            const SizedBox(height: 32),
            _buildButtons(context),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
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
        const SizedBox(height: 8),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter group name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 6),
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
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Enter group description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'This is the current description of the group',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEditPeopleSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit People',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.group.users.map(
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
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : 'A',
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${user.firstName} ${user.lastName}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: viewModel.isLoading ? null : _updateGroup,
                icon: viewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  viewModel.isLoading ? 'Editing...' : 'Edit Group',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                      },
                child: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
