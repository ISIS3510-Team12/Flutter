import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:team12_flutter_juggle/data/repositories/telemetry/telemetry_repository.dart';
import 'package:team12_flutter_juggle/data/repositories/telemetry/telemetry_repository_provider.dart';
import 'package:team12_flutter_juggle/ui/telemetry/screen_load_tracker.dart';

class _FakeTelemetryRepository extends TelemetryRepository {
  _FakeTelemetryRepository() : super(Dio());

  final reports = <String>[];

  @override
  Future<bool> registerScreenLoad({
    required String screen,
    required Duration loadTime,
  }) async {
    reports.add(screen);
    return true;
  }
}

Widget _app(_FakeTelemetryRepository repository, AsyncValue<Object?> state) {
  return ProviderScope(
    overrides: [telemetryRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(
      home: ScreenLoadTracker(
        screen: 'demo',
        state: state,
        child: const SizedBox(),
      ),
    ),
  );
}

void main() {
  testWidgets('reports once when the data is already available', (
    tester,
  ) async {
    final repository = _FakeTelemetryRepository();

    await tester.pumpWidget(_app(repository, const AsyncData(1)));
    await tester.pump();
    await tester.pumpWidget(_app(repository, const AsyncData(2)));
    await tester.pump();

    expect(repository.reports, ['demo']);
  });

  testWidgets('reports once when loading finishes with data', (tester) async {
    final repository = _FakeTelemetryRepository();

    await tester.pumpWidget(_app(repository, const AsyncLoading()));
    await tester.pump();
    expect(repository.reports, isEmpty);

    await tester.pumpWidget(_app(repository, const AsyncData(1)));
    await tester.pump();

    expect(repository.reports, ['demo']);
  });

  testWidgets('does not report when loading ends with an error', (
    tester,
  ) async {
    final repository = _FakeTelemetryRepository();

    await tester.pumpWidget(_app(repository, const AsyncLoading()));
    await tester.pumpWidget(
      _app(repository, AsyncError(Exception('failed'), StackTrace.empty)),
    );
    await tester.pump();
    await tester.pumpWidget(_app(repository, const AsyncData(1)));
    await tester.pump();

    expect(repository.reports, isEmpty);
  });
}
