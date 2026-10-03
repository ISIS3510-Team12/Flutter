import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/telemetry/telemetry_repository_provider.dart';

class ScreenLoadViewModel extends Notifier<void> {
  @override
  void build() {}

  Future<void> report({
    required String screen,
    required Duration loadTime,
  }) async {
    final repository = ref.read(telemetryRepositoryProvider);
    await AsyncValue.guard(
      () => repository.registerScreenLoad(screen: screen, loadTime: loadTime),
    );
  }
}
