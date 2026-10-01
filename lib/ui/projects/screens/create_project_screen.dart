import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/projects/viewmodels/project_view_model.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({
    super.key,
    required this.groupId,
    required this.projectRepository,
  });

  final int groupId;
  final ProjectRepository projectRepository;

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  DateTime? selectedDeadline;

  late final ProjectViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = ProjectViewModel(
      projectRepository: widget.projectRepository,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty ||
        description.isEmpty ||
        selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );
      return;
    }

    final createdProject = await viewModel.createProject(
      name: name,
      description: description,
      deadline: selectedDeadline!,
      groupId: widget.groupId,
    );

    if (!mounted) return;

    if (createdProject != null) {
      Navigator.pop(context, createdProject);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.errorMessage ?? 'Failed to create project.',
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create project'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new project',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Add the essentials now. You can update them later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Project name',
                hintText: 'Enter project name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the project',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: deadlineController,
              readOnly: true,
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (selectedDate != null) {
                  setState(() {
                    selectedDeadline = selectedDate;
                    deadlineController.text =
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Deadline',
                hintText: 'Select a date',
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: FilledButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : _createProject,
                  child: viewModel.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Create project'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}