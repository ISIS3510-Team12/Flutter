import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/auth/auth_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/view_models/auth_viewmodel.dart';

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(
  () => AuthViewModel(authRepositoryProvider),
);
