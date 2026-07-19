import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teroka')),
      body: const SunnahEmptyState(
        icon: Icons.explore_outlined,
        title: 'Belum ada koleksi untuk diterokai',
        message:
            'Kategori, situasi dan carian akan menunjukkan kandungan yang '
            'telah diluluskan sahaja.',
      ),
    );
  }
}
