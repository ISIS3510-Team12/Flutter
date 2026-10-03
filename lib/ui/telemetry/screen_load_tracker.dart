import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/telemetry/view_models/screen_load_viewmodel_provider.dart';

class ScreenLoadTracker extends ConsumerStatefulWidget {
  const ScreenLoadTracker({
    super.key,
    required this.screen,
    required this.state,
    required this.child,
  });

  final String screen;
  final AsyncValue<Object?> state;
  final Widget child;

  @override
  ConsumerState<ScreenLoadTracker> createState() => _ScreenLoadTrackerState();
}

class _ScreenLoadTrackerState extends ConsumerState<ScreenLoadTracker> {
  final Stopwatch _stopwatch = Stopwatch()..start();
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _checkLoad();
  }

  @override
  void didUpdateWidget(covariant ScreenLoadTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkLoad();
  }

  void _checkLoad() {
    if (_finished || widget.state.isLoading) return;
    _finished = true;
    if (widget.state.hasError) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _stopwatch.stop();
      unawaited(
        ref
            .read(screenLoadViewModelProvider.notifier)
            .report(screen: widget.screen, loadTime: _stopwatch.elapsed),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
