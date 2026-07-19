# Patch Notes

## Unreleased

### Bahasa Melayu

- Asas tadbir urus projek, polisi kandungan dan runbook release telah disediakan.
- Shell aplikasi Android dan admin web kini boleh dibina dengan navigasi dan
  tetapan paparan asas.
- Baseline struktur Supabase kini merangkumi jadual operasi, enum, kekangan
  pemilikan dan RLS fail-closed tanpa seed data atau kandungan agama. Reset,
  lint dan pgTAP Supabase tempatan masih menunggu Docker.
- Kontrak intake kandungan draft-only kini tersedia: model Dart, lima template
  CSV header-only, schema JSON dan boundary staging/approved yang kosong serta
  diabaikan secara lalai. Tiada sumber, reviewer, dalil atau kandungan agama
  diimport atau diterbitkan.
- CLI validasi CSV draft-only kini menyemak header, schema, metadata sumber,
  duplicate, rujukan silang, hak/display, tarikh izin dan keadaan terjemahan
  BM/English secara read-only. Laporan hanya memaparkan kod koleksi/baris/path;
  ia tidak menulis data, mengimport rekod atau mengisytiharkan kelayakan
  penerbitan. Skrip import sengaja menolak semua penulisan sehingga gate
  workflow server BE-03 tersedia.
- Penjenamaan Flutter lalai telah dibuang daripada shell; aset store raster
  masih menunggu task aset release dan bukan sebahagian daripada mana-mana upload.
- Baseline ujian Flutter kini menggunakan pakej `testing_utils` private untuk
  viewport, MediaQuery dan transisi yang deterministik. Harness aplikasi mobile
  dan admin mengasingkan setup router/provider; amaran hit-test adalah fatal.
  `npm run check:flutter` menjalankan analyze dan ujian bagi semua empat target
  Flutter dari direktori pakej yang betul.
- Quality CI GitHub kini berjalan secara read-only dengan action dipin SHA,
  permission `contents: read`, dan tiga job: kontrak, Flutter quality, serta
  build debug/web smoke. Ia tidak menggunakan secrets, cache, artifact, AAB
  release, Play Console atau deployment. Run `29677407731` lulus pada
  `766e1fb`.
- Tiada kandungan agama telah diterbitkan atau diluluskan.

### English

- Project governance, content policies and release runbooks are now in place.
- Android and web-admin shells can now be built with foundational navigation
  and display settings.
- A fail-closed Supabase structural baseline now covers operational tables,
  enums, ownership constraints and RLS, with no seed data or religious content.
  Local Supabase reset, lint and pgTAP still await Docker.
- A draft-only content intake contract now provides Dart models, five
  header-only CSV templates, JSON Schemas and guarded empty staging/approved
  boundaries. No source, reviewer, evidence or religious content has been
  imported or published.
- A draft-only CSV validation CLI now checks headers, schemas, source metadata,
  duplicates, cross-references, rights/display, permission dates and BM/English
  locale states in read-only preview mode. Its reports expose only
  collection/row/path codes; it writes no data, imports no record and never
  declares publication eligibility. The import executable intentionally refuses
  all writes until the BE-03 server workflow exists.
- Default Flutter branding has been removed; reviewed raster store assets remain
  a later release task and are not part of any upload.
- The Flutter test baseline now uses a private `testing_utils` package for
  deterministic viewports, MediaQuery settings and transitions. Mobile/admin
  harnesses isolate router/provider setup, hit-test warnings are fatal, and
  `npm run check:flutter` runs analysis and tests for all four Flutter targets
  from their package directories.
- GitHub Quality CI now runs read-only with SHA-pinned actions,
  `contents: read` permission, and three jobs for contracts, Flutter quality,
  and debug/web build smoke checks. It uses no secrets, cache, artifacts,
  release AAB, Play Console, or deployment path. Run `29677407731` passed on
  `766e1fb`.
- No religious content has been published or approved.

### Google Play

- Track: none
- Version code: none
- Upload status: no signed release AAB generated or uploaded; local debug APK only
- Review status: not submitted
- Availability: not available

### GitHub

- Branch `codex/sunnah-everyday-build` has the CI workflow/hardening commits
  through `766e1fb` pushed.
- No pull request exists: GitHub's public API reports none for the branch, and
  no authenticated GitHub CLI or browser session is available in this environment.
