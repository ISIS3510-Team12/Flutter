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

  Future<void> _submit() async {
    await ref.read(createTaskViewModelProvider.notifier).submit();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _deadlineController.dispose();
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
