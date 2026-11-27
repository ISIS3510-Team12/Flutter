import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'decision_wheel_view_model.dart';

final decisionWheelViewModelProvider =
    AsyncNotifierProvider.autoDispose<
        DecisionWheelViewModel,
        DecisionWheelState>(
  DecisionWheelViewModel.new,
);
