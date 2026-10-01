import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/home_viewmodel.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository_provider.dart';

final homeViewModelProvider =
    AsyncNotifierProvider<HomeViewModel, HomeState>(
    () => HomeViewModel(authRepositoryProvider)
);