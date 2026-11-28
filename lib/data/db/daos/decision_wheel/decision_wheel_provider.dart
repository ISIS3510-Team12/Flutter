import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/data/db/app_database_provider.dart';
import 'package:team12_flutter_juggle/data/db/daos/decision_wheel/decision_wheel_dao.dart';

final decisionWheelDaoProvider = Provider<DecisionWheelDao>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DecisionWheelDao(database);
});
