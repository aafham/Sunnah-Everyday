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
- Onboarding setempat kini muncul sebelum shell pada pelancaran pertama. Bahasa
  Melayu ialah lalai dan English boleh dipilih semasa onboarding atau kemudian
  di Tetapan. Hanya status onboarding, bahasa, tema, kurangkan animasi dan
  skala teks disimpan pada peranti melalui allowlist; tiada kandungan agama,
  sumber, rekod semakan, refleksi atau kelayakan disimpan.
- Salinan shell mobile kini mempunyai sumber ARB BM/English dan localizations
  Dart yang dijana serta gerbang laluan untuk menghalang deep link shell
  sebelum onboarding lengkap. Tiada data atau dakwaan agama baharu ditambah.
- Kad status harian dan halaman butiran kini fail-closed. Tanpa bundle awam
  yang disahkan, ia hanya memaparkan bahawa kandungan diluluskan belum tersedia.
  Pembaca terbina tidak menyimpan atau memaparkan ID, tajuk, sumber, dalil,
  gred atau teks kandungan, dan tidak membaca CSV draft, staging, approved atau
  rangkaian.
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
- Local onboarding now appears before the shell on first launch. Malay is the
  default and English can be selected during onboarding or later in Settings.
  Only onboarding state, language, theme, reduced motion and text scale are
  allowlisted for on-device storage; no religious content, source, review,
  reflection or credential data is stored.
- The mobile shell now has BM/English ARB sources, generated Dart
  localizations and a route gate that prevents shell deep links before
  onboarding completes. No religious data or claims were added.
- The Daily status card and detail page now fail closed. Until a verified public
  bundle exists, they show only that approved content is unavailable. The
  built-in reader has no ID, title, source, evidence, grade or body fields and
  reads no draft CSV, staging, approved directory or network source.
- No religious content has been published or approved.

### Google Play

- Track: none
- Version code: none
- Upload status: no signed release AAB generated or uploaded; local debug APK only
- Review status: not submitted
- Availability: not available

### GitHub

- Branch `codex/sunnah-everyday-build` has the fail-closed-daily feature commit
  `c8ddbeb` pushed. Its Quality run `29678798552` passed all three jobs; no
  release, AAB or Play operation exists in the workflow.
- No pull request exists: GitHub's public API reports none for the branch, and
  no authenticated GitHub CLI or browser session is available in this environment.
