import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/core/utils/photo_upload_exception.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/view_models/create_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/widgets/related_tasks_section.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_sections.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_photo_picker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_names.dart';
import 'package:shake/shake.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _timeController = TextEditingController();
  ShakeDetector? _shakeDetector;
  bool _isConfirmingReset = false;

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      ref.read(createTaskViewModelProvider.notifier).updateDeadline(picked);
      _deadlineController.text = deadlineDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    ref.read(createTaskViewModelProvider.notifier).updateTime(picked);
    _timeController.text = timeOfDayLabel(picked);
  }

  Future<void> _resetForm() async {
    if (!mounted || _isConfirmingReset) return;

    final current = ref.read(createTaskViewModelProvider);

    if (current.isLoading) return;

    _isConfirmingReset = true;

    try {
      final shouldReset = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reset task form?'),
          content: const Text(
            'This will clear the information you have entered.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Reset'),
            ),
          ],
        ),
      );

      if (!mounted || shouldReset != true) return;

      ref.read(createTaskViewModelProvider.notifier).resetForm();

      _titleController.clear();
      _deadlineController.clear();
      _timeController.clear();
    } finally {
      _isConfirmingReset = false;
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    String? photoError;
    try {
      await ref.read(createTaskViewModelProvider.notifier).submit();
    } on PhotoUploadException catch (e) {
      photoError = e.message;
    }
    if (!mounted) return;
    context.pop();
    if (photoError != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Task saved, but the photo was not uploaded. $photoError',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        if (!mounted) return;
        _resetForm();
      },
      shakeThresholdGravity: 2.7,
      shakeSlopTimeMS: 1000,
      minimumShakeCount: 2,
      useFilter: true,
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _titleController.dispose();
    _deadlineController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(createTaskViewModelProvider);
    return ScreenLoadTracker(
    screen: ScreenNames.createTask,
    state: state,
    child: Scaffold(
      appBar: AppBar(title: const Text('Create Task')),
      bottomNavigationBar: const CustomNavigationBar(),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (form) {
          final notifier = ref.read(createTaskViewModelProvider.notifier);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TaskFieldLabel('SELECTED GROUP', required: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskGroup>(
                  initialValue: form.group,
                  style: taskMenuTextStyle(theme),
                  icon: const Icon(Symbols.arrow_right, size: 20),
                  decoration: taskMenuDecoration(theme),
                  onChanged: (value) {
                    if (value != null) notifier.updateGroup(value);
                  },
                  items: form.groups
                      .map(
                        (group) => DropdownMenuItem(
                          value: group,
                          child: Text(group.name),
                        ),
                      )
                      .toList(),
                ),
                if (form.groups.isEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Create a group first from the Tasks tab to add tasks.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 19),
                const TaskFieldLabel('ASSOCIATED PROJECT'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(form.group?.id),
                  initialValue: form.selectedProject,
                  hint: Text('Select a project', style: taskHintStyle(theme)),
                  style: taskMenuTextStyle(theme),
                  icon: const Icon(Symbols.arrow_right, size: 20),
                  decoration: taskMenuDecoration(theme),
                  onChanged: (value) {
                    if (value != null) notifier.updateSelectedProject(value);
                  },
                  items: form.projects
                      .map(
                        (project) => DropdownMenuItem(
                          value: project,
                          child: Text(project),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel('TASK TITLE', required: true),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  inputFormatters: Validators.taskTitleTextInputFormatters,
                  maxLength: Validators.maxNameLength,
                  onChanged: notifier.updateTitle,
                  decoration: InputDecoration(
                    hintText: 'Enter the task title',
                    hintStyle: taskHintStyle(theme),
                    suffixIcon: IconButton(
                      icon: const Icon(Symbols.cancel),
                      onPressed: () {
                        _titleController.clear();
                        notifier.updateTitle('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: theme.colorScheme.outline),
                    ),
                  ),
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel('TASK TYPE', required: true),
                const SizedBox(height: 8),
                TaskTypeDropdown(
                  value: form.type,
                  onChanged: notifier.updateType,
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel('ASSIGNED MEMBERS', bold: true),
                const SizedBox(height: 8),
                TaskMembersSelector(
                  members: form.members,
                  selectedIds: form.selectedMemberIds,
                  onToggle: notifier.toggleMember,
                  lockedId: form.lockedMemberId,
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel('DEADLINE & TIMING', required: true),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  onTap: _pickDeadline,
                  controller: _deadlineController,
                  decoration: taskTimingDecoration(
                    theme,
                    label: 'Date',
                    hint: 'MM/DD/YYYY',
                    icon: Symbols.calendar_today,
                    helper: 'MM/DD/YYYY',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  onTap: _pickTime,
                  controller: _timeController,
                  decoration: taskTimingDecoration(
                    theme,
                    label: 'Time',
                    hint: 'HH:MM',
                    icon: Symbols.schedule,
                  ),
                ),
                const SizedBox(height: 24),
                TaskFlagSwitches(
                  isPriority: form.isPriority,
                  needsHelp: form.needsHelp,
                  onPriorityChanged: notifier.updateIsPriority,
                  onNeedsHelpChanged: notifier.updateNeedsHelp,
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                const TaskFieldLabel('EVIDENCES'),
                const SizedBox(height: 8),
                TaskPhotoPicker(
                  newPhotoPath: form.photoPath,
                  onPicked: notifier.updatePhotoPath,
                ),
                if (form.candidateTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  RelatedTasksSection(
                    tasks: form.filteredCandidates,
                    selectedIds: form.relatedTaskIds,
                    onQueryChanged: notifier.updateRelatedQuery,
                    onToggle: notifier.toggleRelatedTask,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: form.canSubmit ? _submit : null,
                    icon: const Icon(Symbols.add),
                    label: const Text('Create Task'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}
