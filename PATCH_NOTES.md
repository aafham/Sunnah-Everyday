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
- Kontrak UX mobile/admin kini boleh dikesan dalam token dan ujian sebenar:
  kandungan shell mobile dihadkan kepada 560 logical pixels pada paparan luas,
  admin menggunakan drawer di bawah 960 dan navigation rail pada atau melebihi
  960, serta kandungan admin dihadkan kepada 1040. Ia hanya memperkemas susun
  atur, semantik dan state selamat; tiada kandungan, sumber atau akses backend
  baharu ditambah.
- Baseline RTL dan aksesibiliti PDX-03 kini menggunakan padding halaman mobile
  directional, `BackButtonIcon` yang peka arah, heading app bar semantik, serta
  ujian delegate yang mengesahkan hanya BM/English disokong. Override RTL hanya
  untuk ujian widget; ia tidak mengaktifkan locale RTL atau menambah teks/font
  Arab, kandungan/data agama, sumber, akses backend atau laluan penerbitan.
- MOB-05 kini membolehkan sehingga 50 catatan
  peribadi teks bebas (maksimum 500 aksara setiap satu) disimpan secara lokal
  pada Android. Medan catatan mematikan autocorrect, cadangan, autofill dan
  pembelajaran peribadi IME; catatan boleh dipadam satu persatu atau semuanya
  selepas pengesahan. Jika stor tidak boleh dibuka, aplikasi fail-closed dan
  tidak menggunakan fallback plaintext atau pelayar. Tiada catatan dihantar ke
  rangkaian, admin, analitik atau export.
- Bookmark kandungan, sejarah paparan dan penjejakan amalan masih belum
  tersedia kerana bundle awam dengan rujukan kandungan immutable belum wujud;
  aplikasi tidak mencipta ID kandungan palsu. Konfigurasi backup Android kini
  mematikan backup serta mengecualikan domain aplikasi untuk peraturan legacy,
  cloud dan device-transfer. Ini bukan dakwaan secure erase atau deklarasi
  Play Data Safety lengkap.
- MOB-06 menambah semantik dan key ujian stabil untuk kawalan tema, kurangkan
  animasi dan saiz teks. Ujian widget kini mengesahkan pilihan Sistem/Cerah/
  Gelap, simpanan setempat, gabungan reduced motion setempat dengan OS, skala
  teks 90–150% tanpa meratakan lengkung OS, semantik BM/English dan capaian
  kawalan pada teks besar. Tiada kandungan, sumber, akaun, permission,
  rangkaian atau laluan penerbitan baharu.
- MOB-07 menambah deep link Android khusus `sunnah://` untuk hos `daily`,
  `content` dan `correction`, tetapi ia hanya memetakan URI yang ketat kepada
  halaman status statik atau ralat mesra yang dilokalkan. Semua URI luaran
  ditapis sebelum laluan onboarding; token legap tidak dipaparkan, disimpan,
  dihantar ke rangkaian atau dilog. Tiada kandungan, App Link/HTTPS,
  permission, akaun atau release path baharu ditambah.
- QLT-02 menambah smoke test Android setempat pada `emulator-5554` untuk
  onboarding, state kandungan selamat, navigasi dan Tetapan tanpa fixture
  kandungan. Regresi 150% BM/English menguji semantik, fokus, keyboard recovery
  dan token legap tidak didedahkan. `npm run test:mobile-security` pula
  memeriksa manifest sumber, pola rangkaian/SDK produksi, konfigurasi signing
  release dan calon credential yang ditrack secara read-only. Ini bukan audit
  release, Data Safety atau keselamatan peranti menyeluruh.
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
- The mobile/admin UX contract is now backed by shared tokens and widget tests:
  mobile shell content is capped at 560 logical pixels on wider displays, admin
  uses a drawer below 960 and a navigation rail at or above 960, and admin
  content is capped at 1040. This changes layout, semantics and safe states
  only; it adds no content, source or backend access.
- The PDX-03 RTL/accessibility baseline now uses directional mobile page
  padding, a direction-aware `BackButtonIcon`, semantic app-bar headings and a
  delegate test proving exactly BM/English support. The RTL override is only
  for widget tests; it does not enable an RTL locale or add Arabic text/font,
  religious content/data, sources, backend access or a publication path.
- MOB-05 now supports up to 50 local Android free-text
  private reflections (500 characters each). The field disables autocorrect,
  suggestions, autofill and IME personalized learning; reflections can be
  deleted individually or all at once after confirmation. If storage cannot
  open, the app fails closed and does not use a plaintext or browser fallback.
  No reflection reaches a network, admin, analytics or export path.
- Content bookmarks, viewed history and practice tracking are still unavailable
  because no immutable public-bundle content reference exists; the app does not
  create fake content IDs. Android backup configuration now disables backup and
  excludes application domains in legacy, cloud and device-transfer rules. This
  is not a secure-erasure claim or a completed Play Data Safety declaration.
- MOB-06 adds stable semantics and test keys for the theme, reduced-motion and
  text-size controls. Widget tests now verify System/Light/Dark selection,
  local persistence, combined local/OS reduced motion, 90–150% text scaling
  without flattening the OS curve, BM/English semantics and control reachability
  at large text. No content, source, account, permission, network or
  publication path was added.
- MOB-07 adds the `sunnah://` Android custom scheme for `daily`, `content` and
  `correction`, while mapping only strict URI shapes to a static status or
  localized friendly-error surface. Every external URI is filtered before the
  onboarding route; opaque tokens are not rendered, stored, sent over a
  network or logged. No content, HTTPS App Link, permission, account or
  release path was added.
- QLT-02 adds a device-local Android smoke on `emulator-5554` for onboarding,
  safe content states, navigation and Settings without a content fixture.
  150% BM/English regressions cover semantics, focus, keyboard recovery and
  opaque-token non-disclosure. `npm run test:mobile-security` read-only checks
  source manifests, production networking/SDK patterns, release-signing
  configuration and tracked credential candidates. This is not a release,
  Data Safety or comprehensive device-security audit.
- No religious content has been published or approved.

### Google Play

- Track: none
- Version code: none
- Upload status: no signed release AAB generated or uploaded; local debug APK only
- Review status: not submitted
- Availability: not available

### GitHub

- Branch `codex/sunnah-everyday-build` has the mobile quality regression commit
  `2daac26` pushed. Its Quality run `29684226127` passed
  contracts, Flutter quality and debug/web smoke. No release, AAB or Play
  operation exists in the workflow.
- No pull request exists: GitHub's public API reports none for the branch, and
  no authenticated GitHub CLI or browser session is available in this environment.
