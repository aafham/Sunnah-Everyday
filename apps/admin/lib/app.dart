import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'src/admin_router.dart';

class SunnahEverydayAdminApp extends StatefulWidget {
  const SunnahEverydayAdminApp({super.key});

  @override
  State<SunnahEverydayAdminApp> createState() => _SunnahEverydayAdminAppState();
}

class _SunnahEverydayAdminAppState extends State<SunnahEverydayAdminApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAdminRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sunnah Everyday Admin',
      debugShowCheckedModeBanner: false,
      theme: sunnahLightTheme(),
      darkTheme: sunnahDarkTheme(),
      routerConfig: _router,
    );
  }
}
