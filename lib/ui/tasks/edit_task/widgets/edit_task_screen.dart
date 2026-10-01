import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/photo_upload_exception.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/edit_task/view_models/edit_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_photo_picker.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _deadlineController = TextEditingController();
  final _timeController = TextEditingController();

  bool _controllersFilled = false;

  Future<void> _pickDeadline(DateTime initialDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.isBefore(now) ? initialDate : now,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      final provider = editTaskViewModelProvider(widget.taskId);
      ref.read(provider.notifier).updateDeadline(picked);
      _deadlineController.text = deadlineDate(picked);
    }
  }

  Future<void> _pickTime(TimeOfDay initialTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final provider = editTaskViewModelProvider(widget.taskId);
      ref.read(provider.notifier).updateTime(picked);
      _timeController.text = timeOfDayLabel(picked);
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    String? photoError;
    try {
      await ref
          .read(editTaskViewModelProvider(widget.taskId).notifier)
          .submit();
    } on PhotoUploadException catch (e) {
      photoError = e.message;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
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
  void dispose() {
    _deadlineController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final provider = editTaskViewModelProvider(widget.taskId);
    final state = ref.watch(provider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      bottomNavigationBar: const CustomNavigationBar(),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (form) {
          if (!_controllersFilled) {
            _deadlineController.text = deadlineDate(form.deadline);
            _timeController.text = timeOfDayLabel(form.time);
            _controllersFilled = true;
          }
          final notifier = ref.read(provider.notifier);
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
                const SizedBox(height: 19),
                const TaskFieldLabel('ASSOCIATED PROJECT'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey(form.group?.id),
                  initialValue: form.selectedProject,
                  hint: const Text('Select a project'),
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
                const TaskFieldLabel('TASK TYPE', required: true),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskType>(
                  initialValue: form.type,
                  style: taskMenuTextStyle(theme),
                  icon: const Icon(Symbols.arrow_right, size: 20),
                  decoration: taskMenuDecoration(theme),
                  onChanged: (value) {
                    if (value != null) notifier.updateType(value);
                  },
                  items: TaskType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel('CURRENT ASSIGNED MEMBERS', bold: true),
                const SizedBox(height: 8),
                TaskMembersSelector(
                  members: form.members,
                  selectedIds: form.selectedMemberIds,
                  onToggle: notifier.toggleMember,
                ),
                const SizedBox(height: 19),
                const TaskFieldLabel(
                  'CURRENT DEADLINE & TIMING',
                  required: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  readOnly: true,
                  onTap: () => _pickDeadline(form.deadline),
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
                  onTap: () => _pickTime(form.time),
                  controller: _timeController,
                  decoration: taskTimingDecoration(
                    theme,
                    label: 'Time',
                    hint: 'HH:MM',
                    icon: Symbols.schedule,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const SizedBox(
                      width: 130,
                      child: TaskFieldLabel('IS PRIORITY'),
                    ),
                    Switch(
                      value: form.isPriority,
                      onChanged: notifier.updateIsPriority,
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 130,
                      child: TaskFieldLabel('NEEDS HELP'),
                    ),
                    Switch(
                      value: form.needsHelp,
                      onChanged: notifier.updateNeedsHelp,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const TaskFieldLabel('EVIDENCES'),
                const SizedBox(height: 8),
                TaskPhotoPicker(
                  newPhotoPath: form.newPhotoPath,
                  currentPhoto: form.currentPhoto,
                  onPicked: notifier.updatePhotoPath,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimary,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _submit,
                        icon: const Icon(Symbols.check),
                        label: const Text('Edit task'),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.onPrimaryContainer,
                          foregroundColor: scheme.primaryContainer,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Symbols.close),
                        label: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _typeLabel(TaskType type) {
  switch (type) {
    case TaskType.coding:
      return 'Coding';
    case TaskType.design:
      return 'Design';
    case TaskType.writing:
      return 'Writing';
    case TaskType.research:
      return 'Research';
  }
}
