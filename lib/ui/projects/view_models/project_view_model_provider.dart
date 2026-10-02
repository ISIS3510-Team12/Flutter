import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/project/project_repository.dart';
import 'package:team12_flutter_juggle/data/services/project/project_api_client.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';
import 'package:team12_flutter_juggle/ui/projects/view_models/project_view_model.dart';

final projectApiClientProvider = Provider<ProjectApiClient>((ref) {
  final dio = ref.watch(dioProvider);

  return ProjectApiClient(dio);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final apiClient = ref.watch(projectApiClientProvider);

  return ProjectRepository(apiClient);
});

final projectViewModelProvider =
    AsyncNotifierProvider<ProjectViewModel, ProjectDetailState?>(
  ProjectViewModel.new,
);