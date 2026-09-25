import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/tasks/task_repository.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());
