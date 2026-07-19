import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared themes preserve the requested brightness', () {
    expect(sunnahLightTheme().brightness, Brightness.light);
    expect(sunnahDarkTheme().brightness, Brightness.dark);
  });

  test('deep forest token remains stable for brand consistency', () {
    expect(SunnahColors.deepForest, const Color(0xFF123F35));
  });
}
