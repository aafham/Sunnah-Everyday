import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnah_everyday_admin/app.dart';

void main() {
  testWidgets('admin shell starts with an honest backend setup state', (
    tester,
  ) async {
    await tester.pumpWidget(const SunnahEverydayAdminApp());
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(const SunnahEverydayAdminApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draf'));
    await tester.pumpAndSettle();

    expect(
      find.text('Draf menunggu rekod sumber dan semakan yang diperlukan.'),
      findsOneWidget,
    );
  });

  testWidgets('wide admin shell uses a navigation rail and changes routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SunnahEverydayAdminApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
    await tester.tap(find.text('Semakan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Queue hadith, fiqh, bahasa dan kelulusan akhir.'),
      findsOneWidget,
    );
  });
}
