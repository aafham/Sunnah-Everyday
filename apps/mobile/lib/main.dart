import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';

import 'app.dart';
import 'src/app_preferences.dart';
import 'src/private_reflections.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferencesStore = await createLocalAppPreferencesStore();
  final privateReflectionStore = createPrivateReflectionStore();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesStoreProvider.overrideWithValue(preferencesStore),
        privateReflectionStoreProvider.overrideWithValue(
          privateReflectionStore,
        ),
      ],
      child: const SunnahEverydayApp(),
    ),
  );
}
