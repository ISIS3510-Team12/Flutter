import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/ui/groups/viewmodels/new_group_view_model.dart';
import 'package:team12_flutter_juggle/data/repositories/user/user_repository.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({
    super.key,
    required this.groupRepository,
    required this.userRepository,
  });

  final GroupRepository groupRepository;
  final UserRepository userRepository;

  
  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  late final NewGroupViewModel viewModel = NewGroupViewModel(
    groupRepository: widget.groupRepository,
  );

  final TextEditingController nameController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<GroupUserOption> users = [];

  final Set<String> selectedUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final backendUsers = await widget.userRepository.getUsers();

      if (!mounted) return;

      setState(() {
        users = backendUsers.map(
          (user) => GroupUserOption(
            userId: user.userId,
            name: '${user.firstName} ${user.lastName}',
            email: user.email,
            initial: user.firstName.isNotEmpty
                ? user.firstName[0].toUpperCase()
                : '?',
          ),
        ).toList();
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load users: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    viewModel.dispose();
    nameController.dispose();
    classController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final success = await viewModel.createGroup(
      name: nameController.text.trim(),
      description: classController.text.trim(),
      userIds: selectedUserIds.toList(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Error creating group',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

            ...users.map(
              (user) => _buildUserTile(
                context: context,
                user: user,
              ),
            ),

            ElevatedButton(
              onPressed: viewModel.isLoading ? null : _createGroup,
              child: viewModel.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Create Group'),
            ),
          ],
        ),
      ),
    );
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
    );
  }

  Widget _buildUserTile({
    required BuildContext context,
    required GroupUserOption user,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user.initial,
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
                  user.name,
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
}

class GroupUserOption {
  const GroupUserOption({
    required this.userId,
    required this.name,
    required this.email,
    required this.initial,
  });

  final String userId;
  final String name;
  final String email;
  final String initial;
}