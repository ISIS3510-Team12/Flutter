import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/telemetry/view_models/feature_session_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/telemetry/view_models/feature_session_viewmodel_provider.dart';

mixin FeatureSessionMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  late final DateTime _openedAt;
  late final FeatureSessionViewModel _sessions;
  bool _completed = false;

  String get featureName;

  void markFeatureCompleted() {
    _completed = true;
  }

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
    _sessions = ref.read(featureSessionViewModelProvider.notifier);
  }

  @override
  void dispose() {
    final closedAt = DateTime.now();
    if (closedAt.isAfter(_openedAt)) {
      _sessions.report(
        feature: featureName,
        openedAt: _openedAt,
        closedAt: closedAt,
        completed: _completed,
      );
    }
    super.dispose();
  }
}
