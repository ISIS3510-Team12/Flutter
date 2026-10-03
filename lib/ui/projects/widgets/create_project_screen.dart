import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key, required this.groupId});

  final int groupId;

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();

  DateTime? selectedDeadline;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    final createdProject = await ref
        .read(projectCreateViewModelProvider.notifier)
        .createProject(
          name: name,
          description: description,
          deadline: selectedDeadline!,
          groupId: widget.groupId,
        );

    if (!mounted) return;

    if (createdProject != null) {
      context.pop(createdProject);
      return;
    }

    final state = ref.read(projectCreateViewModelProvider);

    final errorMessage = state.hasError
        ? state.error.toString()
        : 'Failed to create project.';

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final projectState = ref.watch(projectCreateViewModelProvider);

    final isLoading = projectState.isLoading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create project'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              readOnly: true,
              onTap: isLoading
                  ? null
                  : () async {
                      final selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          final theme = Theme.of(context);
                          return Theme(
                            data: theme.copyWith(
                              datePickerTheme: theme.datePickerTheme.copyWith(
                                headerHeadlineStyle: theme
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 24, height: 1.0),
                              ),
                            ),
                            child: MediaQuery(
                              data: MediaQuery.of(context).copyWith(
                                textScaler: const TextScaler.linear(1.0),
                              ),
                              child: child!,
                            ),
                          );
                        },
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
                suffixIcon: const Icon(Icons.calendar_today_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: FilledButton(
                  onPressed: isLoading ? null : _createProject,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
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
