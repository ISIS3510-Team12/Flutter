import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:team12_flutter_juggle/data/local/hive_store.dart';
import 'package:team12_flutter_juggle/data/local/pending_op.dart';
import 'package:team12_flutter_juggle/data/repositories/location/location_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository_provider.dart';
import 'package:team12_flutter_juggle/data/sync/outbox_store.dart';
import 'package:team12_flutter_juggle/data/sync/outbox_sync_service.dart';
import 'package:team12_flutter_juggle/data/sync/sync_status.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/calendar/view_models/calendar_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/location/view_models/location_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_overview_provider.dart';
import 'package:team12_flutter_juggle/ui/tasks/tasks/view_models/tasks_viewmodel_provider.dart';

String? _currentUid(Ref ref) {
  try {
    return ref.read(firebaseAuthProvider).currentUser?.uid;
  } catch (_) {
    return null;
  }
}

final outboxStoreProvider = Provider<OutboxStore>(
  (ref) => OutboxStore(Hive.box<String>(HiveBoxes.pendingOps)),
);

final outboxSyncServiceProvider = Provider<OutboxSyncService>((ref) {
  final service = OutboxSyncService(
    store: ref.watch(outboxStoreProvider),
    repository: () => ref.read(taskRepositoryProvider),
    locationRepository: () => ref.read(locationRepositoryProvider),
    userId: () => _currentUid(ref),
    isOnline: () => ref.read(isOnlineProvider),
    onSynced: (types) {
      if (types.contains(PendingOpType.createTask)) {
        ref.invalidate(tasksViewModelProvider);
        ref.invalidate(tasksOverviewProvider);
        ref.invalidate(calendarViewModelProvider);
        ref.invalidate(homeViewModelProvider);
      }
      if (types.contains(PendingOpType.saveLocation)) {
        ref.invalidate(locationViewModelProvider);
      }
    },
  );
  ref.onDispose(service.dispose);
  ref.listen<bool>(isOnlineProvider, (_, online) {
    if (online) service.flush();
  });
  ref.listen(authStateProvider, (_, next) {
    if (next.value != null) service.flush();
  }, onError: (_, _) {});
  final lifecycle = AppLifecycleListener(onResume: service.flush);
  ref.onDispose(lifecycle.dispose);
  service.flush();
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>(
  (ref) => ref.watch(outboxSyncServiceProvider).watch(),
);

final pendingOpsProvider = StreamProvider<List<PendingOp>>((ref) {
  final uid = ref.watch(authStateProvider).value?.userId;
  if (uid == null) return Stream.value(const []);
  return ref
      .watch(outboxStoreProvider)
      .watch()
      .map((ops) => ops.where((op) => op.userId == uid).toList());
});
