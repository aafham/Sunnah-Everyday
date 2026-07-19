import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/app.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
import 'package:sunnaheveryday/src/app_router.dart';
import 'package:testing_utils/testing_utils.dart';

typedef MobileContainerSetup =
    FutureOr<void> Function(ProviderContainer container);

Future<ProviderContainer> pumpMobileApp(
  WidgetTester tester, {
  TestViewport viewport = SunnahTestViewports.mobile,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  AppPreferencesStore? preferencesStore,
  bool onboardingCompleted = true,
  String initialLocation = MobilePath.today,
  MobileContainerSetup? configure,
}) async {
  final container = ProviderContainer(
    overrides: [
      appPreferencesStoreProvider.overrideWithValue(
        preferencesStore ??
            InMemoryAppPreferencesStore(
              initialValues: {
                AppPreferencesStorageKey.onboardingCompleted:
                    onboardingCompleted,
              },
            ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await configure?.call(container);

  await pumpSunnahTestWidget(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: SunnahEverydayApp(initialLocation: initialLocation),
    ),
    viewport: viewport,
    textScaler: textScaler,
    disableAnimations: disableAnimations,
  );
  return container;
}
