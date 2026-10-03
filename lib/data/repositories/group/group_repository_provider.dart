import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/group/group_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return GroupRepository(dio);
});