import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';
import 'package:team12_flutter_juggle/ui/tasks/edit_task/view_models/edit_task_viewmodel_provider.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _notesController = TextEditingController();
  final _deadlineController = TextEditingController();

  bool _controllersFilled = false;

  Future<void> _pickDeadline(DateTime initialDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final provider = editTaskViewModelProvider(widget.taskId);
      ref.read(provider.notifier).updateDeadline(picked);
      _deadlineController.text = deadlineDate(picked);
    }
  }

  Future<void> _submit() async {
    final provider = editTaskViewModelProvider(widget.taskId);
    await ref.read(provider.notifier).submit();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            _notesController.text = form.notes;
            _deadlineController.text = deadlineDate(form.deadline);
            _controllersFilled = true;
          }
          final notifier = ref.read(provider.notifier);
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
                      'Current Group: ${form.task.groupName}',
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('SELECTED TASK *', style: theme.textTheme.labelMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Symbols.star),
                      const SizedBox(width: 12),
                      Expanded(child: Text(form.task.title)),
                    ],
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
                Text(
                  'CURRENT ASSIGNED MEMBERS',
                  style: theme.textTheme.labelMedium,
                ),
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
                Text(
                  'CURRENT DEADLINE & TIMING *',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  readOnly: true,
                  onTap: () => _pickDeadline(form.deadline),
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    hintText: 'MM/DD/YYYY',
                    suffixIcon: const Icon(Symbols.calendar_today),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Symbols.check),
                        label: const Text('Edit task'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
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
