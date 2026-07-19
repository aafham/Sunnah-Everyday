import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({
    required this.title,
    required this.description,
    required this.emptyTitle,
    super.key,
  });

  final String title;
  final String description;
  final String emptyTitle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: SunnahLayout.adminContentMaxWidth,
          ),
          child: ListView(
            padding: SunnahLayout.adminPagePadding,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 28),
              const SunnahSectionCard(
                eyebrow: 'Status sistem',
                title: 'Konfigurasi backend diperlukan',
                child: Text(
                  'Sambungan Supabase dan peranan admin belum dikonfigurasi. '
                  'Tiada kandungan, sumber atau rekod semakan dipaparkan.',
                ),
              ),
              const SizedBox(height: 32),
              SunnahEmptyState(
                icon: Icons.admin_panel_settings_outlined,
                title: emptyTitle,
                message:
                    'CMS akan menguatkuasakan workflow, hak penggunaan dan '
                    'jejak audit selepas backend disediakan.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
