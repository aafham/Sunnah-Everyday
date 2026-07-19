import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_preferences.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final controller = ref.read(appPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Tetapan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Paparan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          Text('Tema', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<AppThemeSetting>(
            segments: const [
              ButtonSegment(
                value: AppThemeSetting.system,
                label: Text('Sistem'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: AppThemeSetting.light,
                label: Text('Cerah'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: AppThemeSetting.dark,
                label: Text('Gelap'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {preferences.themeSetting},
            onSelectionChanged: (value) => controller.selectTheme(value.first),
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kurangkan animasi'),
            subtitle: const Text('Hadkan pergerakan yang tidak penting.'),
            value: preferences.reduceMotion,
            onChanged: controller.setReduceMotion,
          ),
          const Divider(height: 32),
          Text('Saiz teks', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: preferences.textScale,
            min: 0.9,
            max: 1.5,
            divisions: 6,
            label: '${(preferences.textScale * 100).round()}%',
            onChanged: controller.setTextScale,
          ),
          Text(
            'Pratonton teks yang selesa untuk dibaca.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 40),
          Semantics(
            header: true,
            child: Text(
              'Privasi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Akaun pengguna tidak diperlukan. Fungsi bookmark dan catatan '
            'peribadi belum tersedia dan tidak dihantar daripada shell ini.',
          ),
        ],
      ),
    );
  }
}
