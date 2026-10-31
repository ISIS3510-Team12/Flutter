import 'package:flutter/widgets.dart';
import 'package:shake/shake.dart';

mixin ShakeResetMixin<T extends StatefulWidget> on State<T> {
  ShakeDetector? _shakeDetector;
  bool _isConfirmingReset = false;

  void startShakeDetector(Future<void> Function() onShake) {
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        if (!mounted) return;
        onShake();
      },
      shakeThresholdGravity: 2.7,
      shakeSlopTimeMS: 1000,
      minimumShakeCount: 2,
      useFilter: true,
    );
  }

  void stopShakeDetector() {
    _shakeDetector?.stopListening();
  }

  Future<void> runGuardedReset(Future<void> Function() action) async {
    if (!mounted || _isConfirmingReset) return;

    _isConfirmingReset = true;

    try {
      await action();
    } finally {
      _isConfirmingReset = false;
    }
  }
}
