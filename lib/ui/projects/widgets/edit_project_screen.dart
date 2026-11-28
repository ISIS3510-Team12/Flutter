import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_dialog.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_mixin.dart';
import 'package:team12_flutter_juggle/ui/core/utils/network_exceptions.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/edit_project_view_model.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_names.dart';
import 'package:team12_flutter_juggle/ui/telemetry/feature_session_mixin.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  const EditProjectScreen({
    super.key,
    required this.projectId,
    required this.groupId,
  });

  final int projectId;
  final int groupId;

  @override
  ConsumerState<EditProjectScreen> createState() =>
      _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(
      editProjectViewModelProvider((
        projectId: widget.projectId,
        groupId: widget.groupId,
      )),
    );

    return ScreenLoadTracker(
      screen: ScreenNames.editProject,
      state: editState,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Project'),
        ),
        body: editState.when(
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
                    'Could not load project information.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(
                        editProjectViewModelProvider((
                          projectId: widget.projectId,
                          groupId: widget.groupId,
                        )),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (editData) => _EditProjectForm(
            editData: editData,
            projectId: widget.projectId,
            groupId: widget.groupId,
          ),
        ),
        bottomNavigationBar: const CustomNavigationBar(),
      ),
    );
  }
}

class _EditProjectForm extends ConsumerStatefulWidget {
  const _EditProjectForm({
    required this.editData,
    required this.projectId,
    required this.groupId,
  });

  final EditProjectState editData;
  final int projectId;
  final int groupId;

  @override
  ConsumerState<_EditProjectForm> createState() =>
      _EditProjectFormState();
}

class _EditProjectFormState extends ConsumerState<_EditProjectForm>
    with
        ShakeResetMixin<_EditProjectForm>,
        FeatureSessionMixin<_EditProjectForm> {
  @override
  String get featureName => FeatureNames.editProject;

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController deadlineController;

  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDeadline;

  @override
  void initState() {
    super.initState();

    final project = widget.editData.project;

    nameController = TextEditingController(text: project.name);
    descriptionController = TextEditingController(
      text: project.description,
    );

    selectedDeadline = project.deadline;
    deadlineController = TextEditingController(
      text: _formatDate(project.deadline),
    );

    startShakeDetector(_resetForm);
  }

  @override
  void dispose() {
    stopShakeDetector();
    nameController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _resetForm() async {
    if (!mounted) return;

    final currentState = ref.read(
      editProjectViewModelProvider((
        projectId: widget.projectId,
        groupId: widget.groupId,
      )),
    );

    if (currentState.asData?.value.isSaving == true) {
      return;
    }

    await runGuardedReset(() async {
      final shouldReset = await showShakeDiscardDialog(
        context: context,
        entity: 'project',
      );

      if (!mounted || shouldReset != true) return;

      final project = widget.editData.project;

      nameController.text = project.name;
      descriptionController.text = project.description;
      selectedDeadline = project.deadline;
      deadlineController.text = _formatDate(project.deadline);

      _formKey.currentState?.reset();

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Changes discarded.'),
        ),
      );
    });
  }

  Future<void> _selectDeadline(bool isSaving) async {
    if (isSaving) return;

    final today = DateUtils.dateOnly(DateTime.now());
    final currentDeadline = selectedDeadline ?? today;

    final initialDate = currentDeadline.isBefore(today)
        ? today
        : currentDeadline;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(2030),
      builder: (context, child) {
        final theme = Theme.of(context);

        return Theme(
          data: theme.copyWith(
            datePickerTheme: theme.datePickerTheme.copyWith(
              headerHeadlineStyle: theme.textTheme.headlineSmall
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

    if (selectedDate == null || !mounted) return;

    setState(() {
      selectedDeadline = selectedDate;
      deadlineController.text = _formatDate(selectedDate);
    });
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a deadline.'),
        ),
      );
      return;
    }

    final viewModel = ref.read(
      editProjectViewModelProvider((
        projectId: widget.projectId,
        groupId: widget.groupId,
      )).notifier,
    );

    final success = await viewModel.updateProject(
      name: nameController.text.trim(),
      description: descriptionController.text.trim(),
      deadline: selectedDeadline!,
    );

    if (!mounted) return;

    if (success) {
      markFeatureCompleted();
      context.pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          writeFailureMessage(
            viewModel.lastFailure,
            isOnline: ref.read(isOnlineProvider),
            fallback: 'Could not update the project. Please try again.',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final editState = ref.watch(
      editProjectViewModelProvider((
        projectId: widget.projectId,
        groupId: widget.groupId,
      )),
    );

    final isOnline = ref.watch(isOnlineProvider);
    final isSaving = editState.asData?.value.isSaving ?? false;
    final group = widget.editData.group;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit your project',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Update the project information below.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!isOnline) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are offline. Reconnect to save project changes.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Project name
            TextFormField(
              controller: nameController,
              enabled: !isSaving,
              validator: Validators.name,
              inputFormatters: Validators.titleTextInputFormatters,
              maxLength: Validators.maxNameLength,
              decoration: InputDecoration(
                labelText: 'Project name',
                hintText: 'Enter project name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Project description
            TextFormField(
              controller: descriptionController,
              enabled: !isSaving,
              inputFormatters: Validators.descriptionTextInputFormatters,
              maxLines: 2,
              maxLength: Validators.maxDescriptionLength,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the project',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Project deadline
            TextField(
              controller: deadlineController,
              readOnly: true,
              enabled: !isSaving,
              onTap: () => _selectDeadline(isSaving),
              decoration: InputDecoration(
                labelText: 'Deadline',
                hintText: 'Select a date',
                suffixIcon: const Icon(
                  Icons.calendar_today_outlined,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Associated group (read-only)
            Text(
              'Associated group',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      group.name,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: (isSaving || !isOnline)
                        ? null
                        : _updateProject,
                    icon: isSaving
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      isSaving
                          ? 'Editing...'
                          : (!isOnline ? 'Offline' : 'Save changes'),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor:
                          theme.colorScheme.onPrimaryContainer,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
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
                    onPressed: isSaving ? null : () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('Cancel'),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
