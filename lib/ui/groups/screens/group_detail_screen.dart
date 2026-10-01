import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';
import 'package:team12_flutter_juggle/domain/models/project/project.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/groups/screens/edit_group_screen.dart';
import 'package:team12_flutter_juggle/ui/projects/screens/create_project_screen.dart';
import 'package:team12_flutter_juggle/ui/projects/screens/project_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.groupRepository,
    required this.projectRepository,
  });

  final Group group;
  final ProjectRepository projectRepository;
  final GroupRepository groupRepository;

  final List<Map<String, String>> projects = const [
    {
      'title': 'Project 1',
      'subtitle': 'Project description',
    },
    {
      'title': 'Project 2',
      'subtitle': 'Project description',
    },
    {
      'title': 'Project 3',
      'subtitle': 'Project description',
    },
  ];

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> { 
  late Group group;

  @override void initState() { 
      super.initState();
      group = widget.group; 
      _reloadGroup();
    }

  Future<void> _reloadGroup() async {
    final updatedGroup = await widget.groupRepository.getGroup(
      group.id,
    );

    if (!mounted) return;

    setState(() {
      group = updatedGroup;
    });
  }

  Future<void> _createProject() async {
    final createdProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (context) => CreateProjectScreen(
          groupId: group.id,
          projectRepository: widget.projectRepository,
        ),
      ),
    );

    if (!mounted || createdProject == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(
          project: createdProject,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Group detail'),
        actions: [
          IconButton(
            onPressed: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => GroupEditScreen(
                  group: group,
                  groupRepository: widget.groupRepository,
                ),
              ),
            );

            if (!mounted) return;

            if (updated == true) {
              await _reloadGroup();
            }
          },
          icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
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

            _buildMembers(context),

            const SizedBox(height: 32),

            Text(
              'Related projects',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ...widget.projects.map(
              (project) => _buildProjectCard(
                context,
                project,
              ),
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _createProject,
                icon: const Icon(Icons.add),
                label: const Text('Create project'),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      theme.colorScheme.surfaceContainerHighest,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }

  Widget _buildMembers(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: group.users.map((user) {
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
    Map<String, String> project,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.folder_outlined,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['title']!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project['subtitle']!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.change_history,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.settings_outlined,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
