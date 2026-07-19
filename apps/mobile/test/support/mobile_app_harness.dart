import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sunnaheveryday/app.dart';
import 'package:testing_utils/testing_utils.dart';

typedef MobileContainerSetup = void Function(ProviderContainer container);

Future<ProviderContainer> pumpMobileApp(
  WidgetTester tester, {
  TestViewport viewport = SunnahTestViewports.mobile,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
  MobileContainerSetup? configure,
}) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  configure?.call(container);

  await pumpSunnahTestWidget(
    tester,
    UncontrolledProviderScope(
      container: container,
      child: const SunnahEverydayApp(),
    ),
    viewport: viewport,
    textScaler: textScaler,
    disableAnimations: disableAnimations,
  );
  return container;
}
