import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'connectivity_provider.freezed.dart';

@freezed
abstract class ConnectivityState with _$ConnectivityState {
  const ConnectivityState._();

  const factory ConnectivityState({
    @Default({ConnectivityResult.wifi}) Set<ConnectivityResult> results,
    DateTime? lastOnlineAt,
  }) = _ConnectivityState;

  bool get isOnline => results.any((r) => r != ConnectivityResult.none);
}

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

class ConnectivityNotifier extends Notifier<ConnectivityState> {
  bool _streamEmitted = false;

  @override
  ConnectivityState build() {
    final connectivity = ref.read(connectivityProvider);

    final subscription = connectivity.onConnectivityChanged.listen(
      (results) {
        _streamEmitted = true;
        _update(results);
      },
      onError: (Object error, StackTrace stack) =>
          _logError('stream', error, stack),
    );
    ref.onDispose(subscription.cancel);

    final lifecycle = AppLifecycleListener(onResume: refresh);
    ref.onDispose(lifecycle.dispose);

    connectivity.checkConnectivity().then(
      (results) {
        if (!_streamEmitted) _update(results);
      },
      onError: (Object error, StackTrace stack) =>
          _logError('initial check', error, stack),
    );

    return const ConnectivityState();
  }

  Future<void> refresh() async {
    try {
      _update(await ref.read(connectivityProvider).checkConnectivity());
    } catch (error, stack) {
      _logError('refresh', error, stack);
    }
  }

  void _update(List<ConnectivityResult> results) {
    if (!ref.mounted) return;
    final next = results.toSet();
    final wasOnline = state.isOnline;
    final isOnline = next.any((r) => r != ConnectivityResult.none);
    state = state.copyWith(
      results: next,
      lastOnlineAt: wasOnline && !isOnline
          ? DateTime.now()
          : state.lastOnlineAt,
    );
  }

  void _logError(String source, Object error, StackTrace stack) {
    debugPrint('Connectivity $source failed: $error\n$stack');
  }
}

final connectivityNotifierProvider =
    NotifierProvider<ConnectivityNotifier, ConnectivityState>(
      ConnectivityNotifier.new,
    );

final lastOnlineAtProvider = Provider<DateTime?>(
  (ref) =>
      ref.watch(connectivityNotifierProvider.select((s) => s.lastOnlineAt)),
);

final isOnlineProvider = Provider<bool>(
  (ref) => ref.watch(connectivityNotifierProvider.select((s) => s.isOnline)),
);
