import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_app_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/screens/new_group_screen.dart';
import 'package:team12_flutter_juggle/ui/groups/screens/group_detail_screen.dart';
import '../viewmodels/groups_view_model.dart';
import '../widgets/group_card.dart';
import 'package:team12_flutter_juggle/data/repositories/user/user_repository.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({
    super.key,
    required this.groupRepository,
    required this.projectRepository,
    required this.userRepository,
  });

  final GroupRepository groupRepository;
  final ProjectRepository projectRepository;
  final UserRepository userRepository;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late final GroupsViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = GroupsViewModel(
      groupRepository: widget.groupRepository,
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          return Column(
            children: [
              _buildSearchBar(context),

              Expanded(
                child: _buildGroupsContent(context),
              ),

              _buildCreateGroupButton(context),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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

  Widget _buildGroupsContent(BuildContext context) {
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupDetailScreen(
                  group: group,
                  groupRepository: widget.groupRepository,
                  projectRepository: widget.projectRepository,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateGroupButton(BuildContext context) {
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
              final groupCreated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => NewGroupScreen(
                    groupRepository: widget.groupRepository,
                    userRepository: widget.userRepository,
                  ),
                ),
              );

              if (!mounted) return;

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