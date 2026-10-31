import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection() {
  return driftDatabase(
    name: 'juggle',
    native: DriftNativeOptions(
      setup: (database) {
        database.execute('PRAGMA journal_mode = WAL;');
        database.execute('PRAGMA synchronous = NORMAL;');
        database.execute('PRAGMA busy_timeout = 5000;');
      },
    ),
  );
}
