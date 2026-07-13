import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_cable_sizing_pro/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('App boots to the Dashboard tab', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCableSizingProApp());

    // Let the async database load + first frame settle.
    await tester.pumpAndSettle();

    expect(find.text('Auto Cable Sizing Pro'), findsWidgets);
    expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
  });

  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCableSizingProApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Quick'));
    await tester.pumpAndSettle();
    expect(find.text('Main design inputs'), findsOneWidget);

    await tester.tap(find.text('Lookup'));
    await tester.pumpAndSettle();
    expect(find.text('Search by size, family or construction'), findsOneWidget);
  });
}
