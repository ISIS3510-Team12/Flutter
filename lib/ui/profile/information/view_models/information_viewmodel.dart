import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

class InformationState {
  const InformationState({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String firstName;
  final String lastName;
  final String email;

  String get initial => firstName.isEmpty ? '' : firstName[0].toUpperCase();

  InformationState copyWith({String? firstName, String? lastName}) {
    return InformationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
    );
  }
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
