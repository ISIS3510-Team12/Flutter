import 'package:drift/drift.dart';

@DataClassName('CachedUserLocationRow')
class CachedUserLocations extends Table {
  TextColumn get userId => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get notifyWithin => integer()();

  @override
  Set<Column> get primaryKey => {userId};

  @override
  bool get isStrict => true;
}
