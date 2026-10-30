// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:team12_flutter_juggle/data/local/hive_store.dart';
import 'package:team12_flutter_juggle/ui/core/app/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    final directory = Directory.systemTemp.createTempSync('widget_test_hive');
    await tester.runAsync(() async {
      Hive.init(directory.path);
      await Hive.openBox<String>(HiveBoxes.pendingOps);
    });
    await tester.pumpWidget(const ProviderScope(child: App()));

    await tester.pumpAndSettle();

    expect(find.byType(App), findsOneWidget);
  });
}
