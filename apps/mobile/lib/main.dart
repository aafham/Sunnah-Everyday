import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'src/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferencesStore = await createLocalAppPreferencesStore();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesStoreProvider.overrideWithValue(preferencesStore),
      ],
      child: const SunnahEverydayApp(),
    ),
  );
}
