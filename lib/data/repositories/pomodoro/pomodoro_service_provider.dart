import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:team12_flutter_juggle/data/local/hive_store.dart';
import 'package:team12_flutter_juggle/data/local/pomodoro_store.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_notification_repository_provider.dart';
import 'package:team12_flutter_juggle/data/repositories/pomodoro/pomodoro_service.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:team12_flutter_juggle/ui/core/app/service_locator.dart';

final pomodoroStoreProvider = Provider<PomodoroStore>(
  (ref) => PomodoroStore(Hive.box<String>(HiveBoxes.pomodoro)),
);

final pomodoroServiceProvider = Provider<PomodoroService>((ref) {
  final service = PomodoroService(
    store: ref.watch(pomodoroStoreProvider),
    userId: () {
      try {
        return ref.read(firebaseAuthProvider).currentUser?.uid;
      } catch (_) {
        return null;
      }
    },
  );
  ref.onDispose(service.dispose);
  final notifications = ref.watch(pomodoroNotificationRepositoryProvider);
  final subscription = service.changes.listen(
    (_) => notifications.show(service.record.timer),
  );
  ref.onDispose(subscription.cancel);
  ref.listen(
    authStateProvider,
    (_, _) => service.refresh(),
    onError: (_, _) {},
  );
  final lifecycle = AppLifecycleListener(onResume: service.refresh);
  ref.onDispose(lifecycle.dispose);
  service.refresh();
  return service;
});
