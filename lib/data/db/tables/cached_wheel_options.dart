import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_wheels.dart';

@DataClassName('WheelOptionRow')
class WheelOptions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get wheelId => integer().references(
        Wheels,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get optionText => text()();

  IntColumn get position => integer()();

  @override
  bool get isStrict => true;
}