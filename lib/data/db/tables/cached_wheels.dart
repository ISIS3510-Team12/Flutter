import 'package:drift/drift.dart';

@DataClassName('WheelRow')
class Wheels extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get name => text()();

  IntColumn get createdAtUtcMs => integer()();

  @override
  bool get isStrict => true;
}