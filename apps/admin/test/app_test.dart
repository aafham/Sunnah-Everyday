import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_utils/testing_utils.dart';

import 'support/admin_app_harness.dart';

void main() {
  testWidgets('admin shell starts with an honest backend setup state', (
    tester,
  ) async {
    await pumpAdminApp(tester);

    expect(find.text('Papan pemuka'), findsOneWidget);
    expect(find.text('Konfigurasi backend diperlukan'), findsOneWidget);
    expect(
      find.textContaining('Sambungan Supabase dan peranan admin'),
      findsOneWidget,
    );
  });

  testWidgets('narrow admin shell opens the drawer and changes routes', (
    tester,
  ) async {
    await pumpAdminApp(tester);

    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await settleSunnahTestWidget(tester);
    await tester.tap(find.text('Draf'));
    await settleSunnahTestWidget(tester);

    expect(
      find.text('Draf menunggu rekod sumber dan semakan yang diperlukan.'),
      findsOneWidget,
    );
  });

  testWidgets('admin retains a drawer immediately below the wide breakpoint', (
    tester,
  ) async {
    await pumpAdminApp(
      tester,
      viewport: const TestViewport(logicalSize: Size(959, 800)),
    );

    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('wide admin shell uses a navigation rail at the breakpoint', (
    tester,
  ) async {
    await pumpAdminApp(
      tester,
      viewport: const TestViewport(logicalSize: Size(960, 800)),
    );

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.text('Semakan'));
    await settleSunnahTestWidget(tester);

    expect(
      find.text('Queue hadith, fiqh, bahasa dan kelulusan akhir.'),
      findsOneWidget,
    );
  });
}
