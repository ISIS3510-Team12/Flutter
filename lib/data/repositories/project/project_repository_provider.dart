import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ProjectRepository(dio);
});
