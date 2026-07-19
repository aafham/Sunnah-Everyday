import 'package:go_router/go_router.dart';

import 'admin_page.dart';
import 'admin_shell.dart';

abstract final class AdminPath {
  static const dashboard = '/dashboard';
  static const drafts = '/drafts';
  static const reviews = '/reviews';
  static const sources = '/sources';
  static const reports = '/reports';
}

GoRouter createAdminRouter() {
  return GoRouter(
    initialLocation: AdminPath.dashboard,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AdminShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AdminPath.dashboard,
            builder: (context, state) => const AdminPage(
              title: 'Papan pemuka',
              description:
                  'Ringkasan workflow kandungan akan dipaparkan di sini.',
              emptyTitle: 'Sambungan admin diperlukan',
            ),
          ),
          GoRoute(
            path: AdminPath.drafts,
            builder: (context, state) => const AdminPage(
              title: 'Draf',
              description:
                  'Draf menunggu rekod sumber dan semakan yang diperlukan.',
              emptyTitle: 'Tiada draf boleh dipaparkan',
            ),
          ),
          GoRoute(
            path: AdminPath.reviews,
            builder: (context, state) => const AdminPage(
              title: 'Semakan',
              description: 'Queue hadith, fiqh, bahasa dan kelulusan akhir.',
              emptyTitle: 'Tiada queue tersedia',
            ),
          ),
          GoRoute(
            path: AdminPath.sources,
            builder: (context, state) => const AdminPage(
              title: 'Sumber',
              description:
                  'Daftar sumber dan hak penggunaan akan dikawal di sini.',
              emptyTitle: 'Pengurusan sumber belum dihubungkan',
            ),
          ),
          GoRoute(
            path: AdminPath.reports,
            builder: (context, state) => const AdminPage(
              title: 'Laporan',
              description:
                  'Laporan pengguna akan melalui proses triage dan audit.',
              emptyTitle: 'Tiada laporan boleh dipaparkan',
            ),
          ),
        ],
      ),
    ],
  );
}
