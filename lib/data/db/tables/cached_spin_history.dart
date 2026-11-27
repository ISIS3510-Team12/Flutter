import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_wheels.dart';

@DataClassName('SpinHistoryRow')
class SpinHistory extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get wheelId => integer().references(
        Wheels,
        #id,
        onDelete: KeyAction.cascade,
      )();

  TextColumn get selectedOptionText => text()();

  IntColumn get spunAtUtcMs => integer()();

  @override
  bool get isStrict => true;
}