import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/smart/next_task_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final nextTaskRepositoryProvider = Provider(
  (ref) => NextTaskRepository(ref.watch(dioProvider)),
);
