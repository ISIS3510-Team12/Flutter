import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel.dart';

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(
      HomeViewModel.new,
    );
