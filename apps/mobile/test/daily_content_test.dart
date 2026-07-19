import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/src/daily_content.dart';

void main() {
  test('the built-in daily reader fails closed for today and detail', () {
    const reader = FailClosedDailyContentReader();

    expect(reader.readToday(), isA<NoApprovedDailyContent>());
    expect(reader.readDetail(), isA<NoApprovedDailyContent>());
  });

  test(
    'daily content providers expose only the unavailable state by default',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(todayDailyContentProvider),
        isA<NoApprovedDailyContent>(),
      );
      expect(
        container.read(dailyDetailContentProvider),
        isA<NoApprovedDailyContent>(),
      );
    },
  );
}
