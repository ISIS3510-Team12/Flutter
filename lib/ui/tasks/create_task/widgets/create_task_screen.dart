import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/create_task/view_models/create_task_viewmodel_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
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

  Future<void> _pickTimeRange() async {
    final notifier = ref.read(createTaskViewModelProvider.notifier);
    final start = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (start == null || !mounted) return;
    notifier.updateStartTime(start);

    final end = await showTimePicker(
      context: context,
      initialTime: start.replacing(hour: (start.hour + 1) % 24),
    );
    if (end == null) return;
    notifier.updateEndTime(end);

    final form = ref.read(createTaskViewModelProvider).value;
    _timeController.text = form?.timeRangeLabel ?? '';
  }

  Future<void> _submit() async {
    await ref.read(createTaskViewModelProvider.notifier).submit();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
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
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      'Current Group: ${form.groupName}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('TASK TITLE *', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  onChanged: notifier.updateTitle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Text('TASK TYPE *', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskType>(
                  initialValue: form.type,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    if (value != null) notifier.updateType(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Symbols.star),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: TaskType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(_typeLabel(type)),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('ASSOCIATED PROJECT', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: form.selectedProject,
                  hint: const Text('Select a project'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    if (value != null) notifier.updateSelectedProject(value);
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Symbols.star),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: form.projects
                      .map(
                        (project) => DropdownMenuItem(
                          value: project,
                          child: Text(project),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('ASSIGNED MEMBERS', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final member in form.members)
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: GestureDetector(
                            onTap: () => notifier.updateSelectedMember(member),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: member == form.selectedMember
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primaryFixed,
                                  child: Text(
                                    member.isEmpty
                                        ? ''
                                        : member[0].toUpperCase(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(member, style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text('DEADLINE & TIMING *', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  onTap: _pickDeadline,
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    hintText: 'MM/DD/YYYY',
                    suffixIcon: const Icon(Symbols.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  onTap: _pickTimeRange,
                  controller: _timeController,
                  decoration: InputDecoration(
                    hintText: 'HH:MM - HH:MM',
                    suffixIcon: const Icon(Symbols.schedule),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('IS PRIORITY', style: theme.textTheme.labelMedium),
                    const Spacer(),
                    Switch(
                      value: form.isPriority,
                      onChanged: notifier.updateIsPriority,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text('NEEDS HELP', style: theme.textTheme.labelMedium),
                    const Spacer(),
                    Switch(
                      value: form.needsHelp,
                      onChanged: notifier.updateNeedsHelp,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'NOTES & DELIVERABLE LINK',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  onChanged: notifier.updateNotes,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
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
                      minimumSize: const Size.fromHeight(56),
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
