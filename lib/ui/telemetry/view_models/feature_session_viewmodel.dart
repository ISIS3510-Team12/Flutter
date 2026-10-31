import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/telemetry/telemetry_repository_provider.dart';

class FeatureSessionViewModel extends Notifier<void> {
  @override
  void build() {}

  Future<void> report({
    required String feature,
    required DateTime openedAt,
    required DateTime closedAt,
    required bool completed,
  }) async {
    final repository = ref.read(telemetryRepositoryProvider);
    await AsyncValue.guard(
      () => repository.registerFeatureSession(
        feature: feature,
        openedAt: openedAt,
        closedAt: closedAt,
        completed: completed,
      ),
    );
  }
}
