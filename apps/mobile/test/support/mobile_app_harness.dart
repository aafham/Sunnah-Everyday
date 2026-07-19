import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/app.dart';
import 'package:sunnaheveryday/src/app_preferences.dart';
import 'package:sunnaheveryday/src/app_router.dart';
import 'package:sunnaheveryday/src/private_reflections.dart';
import 'package:testing_utils/testing_utils.dart';

typedef MobileContainerSetup =
    FutureOr<void> Function(ProviderContainer container);

Future<ProviderContainer> pumpMobileApp(
  WidgetTester tester, {
  TestViewport viewport = SunnahTestViewports.mobile,
  Brightness platformBrightness = Brightness.light,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection? textDirectionOverride,
  bool disableAnimations = false,
  AppPreferencesStore? preferencesStore,
  PrivateReflectionStore? privateReflectionStore,
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
      privateReflectionStoreProvider.overrideWithValue(
        privateReflectionStore ?? InMemoryPrivateReflectionStore(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await configure?.call(container);

  await pumpSunnahTestWidget(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: SunnahEverydayApp(
        initialLocation: initialLocation,
        testTextDirectionOverride: textDirectionOverride,
      ),
    ),
    viewport: viewport,
    platformBrightness: platformBrightness,
    textScaler: textScaler,
    disableAnimations: disableAnimations,
  );
  return container;
}
