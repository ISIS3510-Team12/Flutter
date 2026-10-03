import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_viewmodel.dart';

final locationViewModelProvider =
    AsyncNotifierProvider.autoDispose<LocationViewModel, LocationState>(
      LocationViewModel.new,
    );
