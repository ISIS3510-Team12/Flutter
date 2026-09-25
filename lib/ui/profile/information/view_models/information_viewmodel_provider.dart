import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'information_viewmodel.dart';

final informationViewModelProvider =
    AsyncNotifierProvider.autoDispose<InformationViewModel, InformationState>(
      InformationViewModel.new,
    );
