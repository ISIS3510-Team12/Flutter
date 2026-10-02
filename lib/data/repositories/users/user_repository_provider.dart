import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/repositories/users/user_repository.dart';
import 'package:team12_flutter_juggle/ui/core/network/dio_provider.dart';

final userRepositoryProvider = Provider(
  (ref) => UserRepository(ref.watch(dioProvider)),
);
