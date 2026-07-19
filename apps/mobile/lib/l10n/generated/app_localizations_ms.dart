// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Sunnah Everyday';

  @override
  String get navigationSemantics => 'Navigasi utama';

  @override
  String get navToday => 'Hari Ini';

  @override
  String get navExplore => 'Teroka';

  @override
  String get navSaved => 'Simpanan';

  @override
  String get navSettings => 'Tetapan';

  @override
  String get todayHeading => 'Hari Ini';

  @override
  String get todayIntro =>
      'Satu ruang tenang untuk belajar langkah demi langkah.';

  @override
  String get contentStatusEyebrow => 'Status kandungan';

  @override
  String get noApprovedContentTitle => 'Belum ada kandungan yang diluluskan';

  @override
  String get noApprovedContentMessage =>
      'Kandungan hanya akan dipaparkan selepas rekod sumber, hak penggunaan dan semakan manusia yang diperlukan tersedia.';

  @override
  String get accuracyFirstTitle => 'Ketepatan didahulukan';

  @override
  String get accuracyFirstMessage =>
      'Aplikasi tidak memaparkan dakwaan agama sebelum ia melalui proses kelulusan yang direkodkan.';

  @override
  String get exploreTitle => 'Teroka';

  @override
  String get exploreEmptyTitle => 'Belum ada koleksi untuk diterokai';

  @override
  String get exploreEmptyMessage =>
      'Kategori, situasi dan carian akan menunjukkan kandungan yang telah diluluskan sahaja.';

  @override
  String get savedTitle => 'Simpanan';

  @override
  String get savedEmptyTitle => 'Belum ada simpanan';

  @override
  String get savedEmptyMessage =>
      'Bookmark dan catatan peribadi belum tersedia. Fungsi ini akan dibina sebagai storan setempat pada peranti.';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get displayHeading => 'Paparan';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get malayLanguage => 'Bahasa Melayu';

  @override
  String get englishLanguage => 'English';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Cerah';

  @override
  String get themeDark => 'Gelap';

  @override
  String get reduceMotionTitle => 'Kurangkan animasi';

  @override
  String get reduceMotionSubtitle => 'Hadkan pergerakan yang tidak penting.';

  @override
  String get textSizeTitle => 'Saiz teks';

  @override
  String textScalePercent(int percent) {
    return '$percent%';
  }

  @override
  String get textSizePreview => 'Pratonton teks yang selesa untuk dibaca.';

  @override
  String get privacyHeading => 'Privasi';

  @override
  String get privacyMessage =>
      'Akaun pengguna tidak diperlukan. Fungsi bookmark dan catatan peribadi belum tersedia dan tidak dihantar daripada shell ini.';

  @override
  String get onboardingTitle => 'Selamat datang';

  @override
  String get onboardingDescription =>
      'Pilih bahasa aplikasi sebelum meneruskan. Kandungan hanya muncul selepas semakan dan kelulusan yang diperlukan.';

  @override
  String get onboardingLanguageHeading => 'Pilih bahasa aplikasi';

  @override
  String get continueLabel => 'Teruskan';
}
