import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/tasks/view_task/view_models/view_task_viewmodel_provider.dart';

class TaskPhotoViewer extends ConsumerWidget {
  const TaskPhotoViewer({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final photo = ref.watch(viewTaskViewModelProvider(taskId)).value?.photo;
    return Scaffold(
      backgroundColor: scheme.onSurface,
      appBar: AppBar(
        backgroundColor: scheme.onSurface,
        foregroundColor: scheme.surface,
        title: const Text('Evidences'),
      ),
      body: Center(
        child: photo == null
            ? const CircularProgressIndicator()
            : InteractiveViewer(
                maxScale: 5,
                child: Image.memory(photo, fit: BoxFit.contain),
              ),
      ),
    );
  }
}
