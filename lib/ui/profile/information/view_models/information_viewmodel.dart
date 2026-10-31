import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'information_viewmodel.freezed.dart';

@freezed
abstract class InformationState with _$InformationState {
  const InformationState._();

  const factory InformationState({
    required String firstName,
    required String lastName,
    required String email,
  }) = _InformationState;

  String get initial => firstName.isEmpty ? '' : firstName[0].toUpperCase();

  bool get isEmpty => firstName.isEmpty && lastName.isEmpty;
}

class InformationViewModel extends AsyncNotifier<InformationState> {
  @override
  Future<InformationState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return InformationState(
      firstName: user?.firstName ?? '',
      lastName: user?.lastName ?? '',
      email: user?.email ?? '',
    );
  }

  void updateFirstName(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(firstName: value));
  }

  void updateLastName(String value) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(lastName: value));
  }
}
