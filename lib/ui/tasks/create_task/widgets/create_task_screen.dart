import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/photo_upload_exception.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task_group.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/view_models/create_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_form_widgets.dart';
import 'package:team12_flutter_juggle/ui/tasks/widgets/task_photo_picker.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _timeController = TextEditingController();

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

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    String? photoError;
    try {
      await ref.read(createTaskViewModelProvider.notifier).submit();
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
    _titleController.dispose();
    _deadlineController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(createTaskViewModelProvider);
    return Scaffold(
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
                      borderSide: const BorderSide(color: taskOutlineColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: taskOutlineColor),
                    ),
                  ),
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
                const TaskFieldLabel('ASSIGNED MEMBERS', bold: true),
                const SizedBox(height: 8),
                TaskMembersSelector(
                  members: form.members,
                  selectedIds: form.selectedMemberIds,
                  onToggle: notifier.toggleMember,
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
                const SizedBox(height: 16),
                const TaskFieldLabel('EVIDENCES'),
                const SizedBox(height: 8),
                TaskPhotoPicker(
                  newPhotoPath: form.photoPath,
                  onPicked: notifier.updatePhotoPath,
                ),
                if (form.candidateTasks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('RELATED TASKS', style: theme.textTheme.labelMedium),
                      const Spacer(),
                      if (form.relatedTaskIds.isNotEmpty)
                        Text(
                          '${form.relatedTaskIds.length} selected',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: notifier.updateRelatedQuery,
                    decoration: InputDecoration(
                      hintText: 'Search for a task...',
                      hintStyle: taskHintStyle(theme),
                      suffixIcon: const Icon(Symbols.search),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _RelatedTasksList(
                    tasks: form.filteredCandidates,
                    selectedIds: form.relatedTaskIds,
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
    );
  }
}

class _RelatedTasksList extends StatelessWidget {
  const _RelatedTasksList({
    required this.tasks,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<Task> tasks;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  static const _itemHeight = 72.0;
  static const _maxVisibleItems = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No tasks found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return Container(
      constraints: const BoxConstraints(
        maxHeight: _itemHeight * _maxVisibleItems,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final candidate = tasks[index];
            return CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  candidate.assigneeInitial,
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              title: Text(
                candidate.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Due date: ${deadlineDate(candidate.deadline)}'),
              value: selectedIds.contains(candidate.id),
              onChanged: (_) => onToggle(candidate.id),
            );
          },
        ),
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
