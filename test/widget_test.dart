import 'package:auto_cable_sizing_pro/main.dart';
import 'package:auto_cable_sizing_pro/models/cable_record.dart';
import 'package:auto_cable_sizing_pro/providers/database_provider.dart';
import 'package:auto_cable_sizing_pro/providers/design_provider.dart';
import 'package:auto_cable_sizing_pro/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _testRecords = <CableRecord>[
  CableRecord(
    id: 'TEST-001',
    construction: '1 x 4C',
    family: 'XLPE/PVC',
    material: 'Copper',
    sizeSqmm: 16,
    cccAmps: 85,
    rOhmPerKm: 1.15,
    xOhmPerKm: 0.08,
    protectionClass: 'MCCB',
    brandGroup: 'Test Brand',
    sourceNote: 'Deterministic widget-test record.',
  ),
  CableRecord(
    id: 'TEST-002',
    construction: '1 x 4C',
    family: 'PVC/PVC',
    material: 'Copper',
    sizeSqmm: 25,
    cccAmps: 101,
    rOhmPerKm: 0.73,
    xOhmPerKm: 0.08,
    protectionClass: 'MCCB',
    brandGroup: 'Test Brand',
    sourceNote: 'Deterministic widget-test record.',
  ),
];

Future<void> _pumpTestApp(WidgetTester tester) async {
  await tester.pumpWidget(
    AutoCableSizingProApp(
      themeProvider: ThemeProvider.test(),
      databaseProvider: DatabaseProvider.seeded(_testRecords),
      designProvider: DesignProvider(),
    ),
  );

  // Process the first frame plus the Quick/Detailed Design post-frame
  // recomputations. Avoid pumpAndSettle so an unrelated progress animation
  // can never make these navigation tests time out.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('App boots to the Dashboard tab', (WidgetTester tester) async {
    await _pumpTestApp(tester);

    expect(find.text('Auto Cable Sizing Pro'), findsWidgets);
    expect(find.byKey(const Key('dashboard_screen')), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Bottom navigation switches tabs', (WidgetTester tester) async {
    await _pumpTestApp(tester);

    await tester.tap(find.byKey(const Key('nav_quick')));
    await tester.pump();
    expect(find.byKey(const Key('quick_design_screen')), findsOneWidget);
    expect(find.text('Main design inputs'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav_lookup')));
    await tester.pump();
    expect(find.byKey(const Key('lookup_screen')), findsOneWidget);
    expect(find.text('Search by size, family or construction'), findsOneWidget);
  });
}
