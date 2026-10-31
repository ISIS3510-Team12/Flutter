import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/data/repositories/smart/next_task_repository_provider.dart';
import 'package:team12_flutter_juggle/domain/models/smart/next_task.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/utils/deadline_format.dart';

part 'next_task_viewmodel.freezed.dart';

const noPendingTasksMessage = 'You have no pending tasks.';

@freezed
abstract class NextTaskCard with _$NextTaskCard {
  const factory NextTaskCard({
    required String taskId,
    required String title,
    required NextTaskReason reason,
    required String semanticLabel,
    String? subtitle,
    String? flagText,
  }) = _NextTaskCard;
}

@freezed
abstract class NextTaskState with _$NextTaskState {
  const NextTaskState._();

  const factory NextTaskState({NextTaskCard? card, String? message}) =
      _NextTaskState;

  bool get hasTask => card != null;
}

NextTaskCard buildNextTaskCard(NextTask task) {
  final due = task.dueAt;
  final subtitleParts = [
    if (task.groupName.isNotEmpty) task.groupName,
    if (due != null)
      task.reason == NextTaskReason.overdue
          ? deadlineDate(due)
          : deadlineText(due),
  ];
  final flagText = task.reasonText;
  return NextTaskCard(
    taskId: task.taskId.toString(),
    title: task.title,
    reason: task.reason,
    flagText: flagText,
    subtitle: subtitleParts.isEmpty ? null : subtitleParts.join(' • '),
    semanticLabel: flagText == null
        ? 'Next task: ${task.title}'
        : 'Next task: ${task.title}. $flagText',
  );
}

class NextTaskViewModel extends AsyncNotifier<NextTaskState> {
  Future<void>? _refreshing;

  @override
  Future<NextTaskState> build() async {
    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(lifecycle.dispose);
    ref.listen<bool>(isOnlineProvider, (previous, online) {
      if (online && previous == false) refresh();
    });
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return const NextTaskState();
    return _load();
  }

  Future<void> refresh() {
    final running = _refreshing;
    if (running != null) return running;
    if (state.isLoading) return Future.value();
    if (ref.read(currentUserProvider).value == null) return Future.value();
    final refreshing = _refresh().whenComplete(() => _refreshing = null);
    _refreshing = refreshing;
    return refreshing;
  }

  Future<void> _refresh() async {
    final keepsCard = state.hasValue;
    if (!keepsCard) state = const AsyncLoading();
    final result = await AsyncValue.guard(_load);
    if (!ref.mounted) return;
    if (result.hasError && keepsCard) return;
    state = result;
  }

  Future<NextTaskState> _load() async {
    final result = await ref.read(nextTaskRepositoryProvider).getNextTask();
    final task = result.task;
    if (task != null) return NextTaskState(card: buildNextTaskCard(task));
    return NextTaskState(message: result.message ?? noPendingTasksMessage);
  }
}
