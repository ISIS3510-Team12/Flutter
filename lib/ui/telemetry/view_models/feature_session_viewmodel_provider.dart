import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/telemetry/view_models/feature_session_viewmodel.dart';

final featureSessionViewModelProvider =
    NotifierProvider<FeatureSessionViewModel, void>(FeatureSessionViewModel.new);
