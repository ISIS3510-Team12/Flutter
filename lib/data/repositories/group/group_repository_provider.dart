import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/user/user_repository.dart';
import 'package:team12_flutter_juggle/data/services/user/user_api_client.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return GroupRepository(dio);
});

final userApiClientProvider = Provider<UserApiClient>((ref) {
  final dio = ref.watch(dioProvider);

  return UserApiClient(dio);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(userApiClientProvider);

  return UserRepository(apiClient);
});