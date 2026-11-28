import 'dart:math';
import 'package:team12_flutter_juggle/data/db/tables/sparse_array.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/data/db/daos/decision_wheel/decision_wheel_provider.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

part 'decision_wheel_view_model.freezed.dart';

class DecisionWheelViewModel extends AsyncNotifier<DecisionWheelState> {
  final SparseArray<List<WheelOptionRow>> _optionsCache =
    SparseArray<List<WheelOptionRow>>();

  @override
  Future<DecisionWheelState> build() async {
    final user = await ref.watch(currentUserProvider.future);

    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final dao = ref.watch(decisionWheelDaoProvider);
    final wheels = await dao.watchWheels(user.userId).first;

    return DecisionWheelState(wheels: wheels);
  }

  Future<int> createWheel(String name) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Wheel name cannot be empty.');
    }

    final user = await ref.read(currentUserProvider.future);

    if (user == null) {
      throw StateError('No authenticated user found.');
    }

    final dao = ref.read(decisionWheelDaoProvider);

    final wheelId = await dao.createWheel(
      userId: user.userId,
      name: normalizedName,
    );

    await _refreshWheels();

    return wheelId;
  }

  Future<void> renameWheel(int wheelId, String name) async {
    final normalizedName = name.trim();

    if (normalizedName.isEmpty) {
      throw ArgumentError('Wheel name cannot be empty.');
    }

    final dao = ref.read(decisionWheelDaoProvider);

    await dao.updateWheelName(
      wheelId: wheelId,
      name: normalizedName,
    );

    await _refreshWheels();
  }

  Future<void> deleteWheel(int wheelId) async {
    final dao = ref.read(decisionWheelDaoProvider);

    await dao.deleteWheel(wheelId);

    await _refreshWheels();
  }


  Future<List<WheelOptionRow>> getOptions(int wheelId) async {
    final cachedOptions = _optionsCache.get(wheelId);

    if (cachedOptions != null) {
      return cachedOptions;
    }

    final dao = ref.read(decisionWheelDaoProvider);
    final options = await dao.watchOptions(wheelId).first;

    _optionsCache.put(wheelId, options);

    return options;
  }

  Future<void> addOption(int wheelId, String optionText) async {
    final normalizedText = optionText.trim();

    if (normalizedText.isEmpty) {
      throw ArgumentError('Option cannot be empty.');
    }

    final dao = ref.read(decisionWheelDaoProvider);

    await dao.addOption(
      wheelId: wheelId,
      optionText: normalizedText,
    );
    _optionsCache.remove(wheelId);
  }

  Future<void> editOption(int optionId, String optionText) async {
    final normalizedText = optionText.trim();

    if (normalizedText.isEmpty) {
      throw ArgumentError('Option cannot be empty.');
    }

    final dao = ref.read(decisionWheelDaoProvider);

    await dao.updateOption(
      optionId: optionId,
      optionText: normalizedText,
    );
    _optionsCache.clear();
  }

  Future<void> deleteOption(int optionId) async {
    final dao = ref.read(decisionWheelDaoProvider);

    await dao.deleteOption(optionId);
    _optionsCache.clear();
  }


  Future<WheelOptionRow> spinWheel(
    int wheelId, {
    required List<WheelOptionRow> options,
  }) async {
    if (options.length < 2) {
      throw StateError(
        'At least two options are required to spin the wheel.',
      );
    }

    final random = Random();
    final selected = options[random.nextInt(options.length)];

    await ref.read(decisionWheelDaoProvider).recordSpin(
          wheelId: wheelId,
          selectedOptionText: selected.optionText,
        );

    state = AsyncData(
      state.requireValue.copyWith(
        selectedOption: selected.optionText,
      ),
    );

    return selected;
  }


  Future<List<SpinHistoryRow>> getSpinHistory(int wheelId) {
    final dao = ref.read(decisionWheelDaoProvider);

    return dao.watchSpinHistory(wheelId).first;
  }

  void clearSelectedOption() {
    final currentState = state;

    if (currentState is AsyncData<DecisionWheelState>) {
      state = AsyncData(
        currentState.value.copyWith(
          selectedOption: null,
        ),
      );
    }
  }


  Future<void> _refreshWheels() async {
    final user = await ref.read(currentUserProvider.future);

    if (user == null) return;

    final dao = ref.read(decisionWheelDaoProvider);
    final wheels = await dao.watchWheels(user.userId).first;

    final currentState = state.requireValue;

    state = AsyncData(
      currentState.copyWith(wheels: wheels),
    );
  }
}

@freezed
abstract class DecisionWheelState with _$DecisionWheelState {
  const factory DecisionWheelState({
    @Default([]) List<WheelRow> wheels,
    String? selectedOption,
  }) = _DecisionWheelState;
}
