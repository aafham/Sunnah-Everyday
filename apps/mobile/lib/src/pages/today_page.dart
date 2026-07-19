import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          Semantics(
            header: true,
            child: Text(
              'Hari Ini',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Satu ruang tenang untuk belajar langkah demi langkah.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const SunnahSectionCard(
            eyebrow: 'Status kandungan',
            title: 'Belum ada kandungan yang diluluskan',
            child: Text(
              'Kandungan hanya akan dipaparkan selepas rekod sumber, hak '
              'penggunaan dan semakan manusia yang diperlukan tersedia.',
            ),
          ),
          const SizedBox(height: 24),
          const SunnahEmptyState(
            icon: Icons.verified_user_outlined,
            title: 'Ketepatan didahulukan',
            message:
                'Aplikasi tidak memaparkan dakwaan agama sebelum ia melalui '
                'proses kelulusan yang direkodkan.',
          ),
        ],
      ),
    );
  }
}
