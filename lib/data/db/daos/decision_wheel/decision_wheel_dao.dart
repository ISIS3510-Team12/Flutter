import 'package:drift/drift.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_wheels.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_wheel_options.dart';
import 'package:team12_flutter_juggle/data/db/tables/cached_spin_history.dart';

part 'decision_wheel_dao.g.dart';

@DriftAccessor(
  tables: [
    Wheels,
    WheelOptions,
    SpinHistory,
  ],
)
class DecisionWheelDao extends DatabaseAccessor<AppDatabase>
    with _$DecisionWheelDaoMixin {
    DecisionWheelDao(super.db);

  Stream<List<WheelRow>> watchWheels(String userId) {
    return (select(wheels)
          ..where((wheel) => wheel.userId.equals(userId))
          ..orderBy([
            (wheel) => OrderingTerm.desc(wheel.createdAtUtcMs),
          ]))
        .watch();
  }

  Future<int> createWheel({
    required String userId,
    required String name,
  }) {
    return into(wheels).insert(
      WheelsCompanion.insert(
        userId: userId,
        name: name,
        createdAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }


  Future<int> updateWheelName({
    required int wheelId,
    required String name,
  }) {
    return (update(wheels)..where((wheel) => wheel.id.equals(wheelId)))
        .write(WheelsCompanion(name: Value(name)));
  }

  Future<int> deleteWheel(int wheelId) {
    return (delete(wheels)..where((wheel) => wheel.id.equals(wheelId))).go();
  }


  Stream<List<WheelOptionRow>> watchOptions(int wheelId) {
    return (select(wheelOptions)
          ..where((option) => option.wheelId.equals(wheelId))
          ..orderBy([
            (option) => OrderingTerm.asc(option.position),
          ]))
        .watch();
  }

  Future<int> addOption({
    required int wheelId,
    required String optionText,
  }) async {
    final existingOptions = await (select(wheelOptions)
          ..where((option) => option.wheelId.equals(wheelId)))
        .get();

    return into(wheelOptions).insert(
      WheelOptionsCompanion.insert(
        wheelId: wheelId,
        optionText: optionText,
        position: existingOptions.length,
      ),
    );
  }


  Future<int> updateOption({
    required int optionId,
    required String optionText,
  }) {
    return (update(wheelOptions)
          ..where((option) => option.id.equals(optionId)))
        .write(
      WheelOptionsCompanion(optionText: Value(optionText)),
    );
  }


  Future<int> deleteOption(int optionId) {
    return (delete(wheelOptions)
          ..where((option) => option.id.equals(optionId)))
        .go();
  }

  Stream<List<SpinHistoryRow>> watchSpinHistory(int wheelId) {
    return (select(spinHistory)
          ..where((spin) => spin.wheelId.equals(wheelId))
          ..orderBy([
            (spin) => OrderingTerm.desc(spin.spunAtUtcMs),
          ]))
        .watch();
  }


  Future<int> recordSpin({
    required int wheelId,
    required String selectedOptionText,
  }) {
    return into(spinHistory).insert(
      SpinHistoryCompanion.insert(
        wheelId: wheelId,
        selectedOptionText: selectedOptionText,
        spunAtUtcMs: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
