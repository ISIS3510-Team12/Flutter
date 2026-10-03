import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/telemetry/telemetry_repository_provider.dart';

class ScreenLoadTracker extends ConsumerStatefulWidget {
  const ScreenLoadTracker({
    super.key,
    required this.screen,
    required this.isLoading,
    required this.child,
  });

  final String screen;
  final bool isLoading;
  final Widget child;

  @override
  ConsumerState<ScreenLoadTracker> createState() =>
      _ScreenLoadTrackerState();
}

class _ScreenLoadTrackerState extends ConsumerState<ScreenLoadTracker> {
  late final Stopwatch _stopwatch;
  bool _tracked = false;

  @override
  void initState() {
    super.initState();

    _stopwatch = Stopwatch()..start();

    if (!widget.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _trackScreenLoad();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ScreenLoadTracker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isLoading && !widget.isLoading) {
      _trackScreenLoad();
    }
  }

  void _trackScreenLoad() {
    if (_tracked) return;

    _tracked = true;
    _stopwatch.stop();

    ref.read(telemetryRepositoryProvider).registerScreenLoad(
          screen: widget.screen,
          loadTime: _stopwatch.elapsed,
        );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}