import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'group_detail_view_model.dart';

final groupDetailViewModelProvider =
    AsyncNotifierProvider.autoDispose.family<
      GroupDetailViewModel,
      GroupDetailState,
      int
    >(
      GroupDetailViewModel.new,
    );