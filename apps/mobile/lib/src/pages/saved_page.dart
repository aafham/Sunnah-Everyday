import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simpanan')),
      body: const SunnahEmptyState(
        icon: Icons.bookmark_outline,
        title: 'Belum ada simpanan',
        message:
            'Bookmark dan catatan peribadi belum tersedia. Fungsi ini akan '
            'dibina sebagai storan setempat pada peranti.',
      ),
    );
  }
}
