import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class HiveBoxes {
  static const pendingOps = 'pending_ops';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveBoxes.pendingOps);
}
