import 'package:flutter_test/flutter_test.dart';
import 'package:sunnah_everyday_admin/app.dart';
import 'package:testing_utils/testing_utils.dart';

Future<void> pumpAdminApp(
  WidgetTester tester, {
  TestViewport viewport = SunnahTestViewports.mobile,
}) => pumpSunnahTestWidget(
  tester,
  const SunnahEverydayAdminApp(),
  viewport: viewport,
);
