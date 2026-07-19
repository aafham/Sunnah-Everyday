import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ms.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ms'),
    Locale('en'),
  ];

  /// Nama aplikasi.
  ///
  /// In ms, this message translates to:
  /// **'Sunnah Everyday'**
  String get appTitle;

  /// Label semantik untuk navigasi bawah.
  ///
  /// In ms, this message translates to:
  /// **'Navigasi utama'**
  String get navigationSemantics;

  /// Destinasi Hari Ini.
  ///
  /// In ms, this message translates to:
  /// **'Hari Ini'**
  String get navToday;

  /// Destinasi Teroka.
  ///
  /// In ms, this message translates to:
  /// **'Teroka'**
  String get navExplore;

  /// Destinasi Simpanan.
  ///
  /// In ms, this message translates to:
  /// **'Simpanan'**
  String get navSaved;

  /// Destinasi Tetapan.
  ///
  /// In ms, this message translates to:
  /// **'Tetapan'**
  String get navSettings;

  /// Tajuk halaman Hari Ini.
  ///
  /// In ms, this message translates to:
  /// **'Hari Ini'**
  String get todayHeading;

  /// Pengenalan ruang Hari Ini tanpa kandungan agama.
  ///
  /// In ms, this message translates to:
  /// **'Satu ruang tenang untuk belajar langkah demi langkah.'**
  String get todayIntro;

  /// Label status kandungan.
  ///
  /// In ms, this message translates to:
  /// **'Status kandungan'**
  String get contentStatusEyebrow;

  /// Keadaan kosong apabila tiada kandungan public.
  ///
  /// In ms, this message translates to:
  /// **'Belum ada kandungan yang diluluskan'**
  String get noApprovedContentTitle;

  /// Penjelasan keselamatan untuk keadaan kandungan kosong.
  ///
  /// In ms, this message translates to:
  /// **'Kandungan hanya akan dipaparkan selepas rekod sumber, hak penggunaan dan semakan manusia yang diperlukan tersedia.'**
  String get noApprovedContentMessage;

  /// Tajuk keadaan keselamatan kandungan.
  ///
  /// In ms, this message translates to:
  /// **'Ketepatan didahulukan'**
  String get accuracyFirstTitle;

  /// Penjelasan bahawa aplikasi gagal tertutup untuk kandungan tidak diluluskan.
  ///
  /// In ms, this message translates to:
  /// **'Aplikasi tidak memaparkan dakwaan agama sebelum ia melalui proses kelulusan yang direkodkan.'**
  String get accuracyFirstMessage;

  /// Tajuk halaman Teroka.
  ///
  /// In ms, this message translates to:
  /// **'Teroka'**
  String get exploreTitle;

  /// Keadaan kosong Teroka.
  ///
  /// In ms, this message translates to:
  /// **'Belum ada koleksi untuk diterokai'**
  String get exploreEmptyTitle;

  /// Penjelasan keselamatan Teroka.
  ///
  /// In ms, this message translates to:
  /// **'Kategori, situasi dan carian akan menunjukkan kandungan yang telah diluluskan sahaja.'**
  String get exploreEmptyMessage;

  /// Tajuk halaman Simpanan.
  ///
  /// In ms, this message translates to:
  /// **'Simpanan'**
  String get savedTitle;

  /// Keadaan kosong Simpanan.
  ///
  /// In ms, this message translates to:
  /// **'Belum ada simpanan'**
  String get savedEmptyTitle;

  /// Penjelasan Simpanan tanpa mendakwa fungsi yang belum wujud.
  ///
  /// In ms, this message translates to:
  /// **'Bookmark dan catatan peribadi belum tersedia. Fungsi ini akan dibina sebagai storan setempat pada peranti.'**
  String get savedEmptyMessage;

  /// Tajuk halaman Tetapan.
  ///
  /// In ms, this message translates to:
  /// **'Tetapan'**
  String get settingsTitle;

  /// Bahagian kawalan paparan.
  ///
  /// In ms, this message translates to:
  /// **'Paparan'**
  String get displayHeading;

  /// Label pilihan bahasa aplikasi.
  ///
  /// In ms, this message translates to:
  /// **'Bahasa'**
  String get languageLabel;

  /// Nama bahasa Melayu.
  ///
  /// In ms, this message translates to:
  /// **'Bahasa Melayu'**
  String get malayLanguage;

  /// Nama bahasa Inggeris.
  ///
  /// In ms, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// Label pilihan tema.
  ///
  /// In ms, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// Pilihan tema sistem.
  ///
  /// In ms, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// Pilihan tema cerah.
  ///
  /// In ms, this message translates to:
  /// **'Cerah'**
  String get themeLight;

  /// Pilihan tema gelap.
  ///
  /// In ms, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// Label pilihan kurangkan gerakan.
  ///
  /// In ms, this message translates to:
  /// **'Kurangkan animasi'**
  String get reduceMotionTitle;

  /// Penjelasan pilihan kurangkan gerakan.
  ///
  /// In ms, this message translates to:
  /// **'Hadkan pergerakan yang tidak penting.'**
  String get reduceMotionSubtitle;

  /// Label kawalan saiz teks.
  ///
  /// In ms, this message translates to:
  /// **'Saiz teks'**
  String get textSizeTitle;

  /// Peratus saiz teks.
  ///
  /// In ms, this message translates to:
  /// **'{percent}%'**
  String textScalePercent(int percent);

  /// Pratonton saiz teks.
  ///
  /// In ms, this message translates to:
  /// **'Pratonton teks yang selesa untuk dibaca.'**
  String get textSizePreview;

  /// Bahagian privasi.
  ///
  /// In ms, this message translates to:
  /// **'Privasi'**
  String get privacyHeading;

  /// Penjelasan privasi semasa.
  ///
  /// In ms, this message translates to:
  /// **'Akaun pengguna tidak diperlukan. Fungsi bookmark dan catatan peribadi belum tersedia dan tidak dihantar daripada shell ini.'**
  String get privacyMessage;

  /// Tajuk onboarding.
  ///
  /// In ms, this message translates to:
  /// **'Selamat datang'**
  String get onboardingTitle;

  /// Penerangan onboarding tanpa kandungan agama baharu.
  ///
  /// In ms, this message translates to:
  /// **'Pilih bahasa aplikasi sebelum meneruskan. Kandungan hanya muncul selepas semakan dan kelulusan yang diperlukan.'**
  String get onboardingDescription;

  /// Arahan pemilihan bahasa onboarding.
  ///
  /// In ms, this message translates to:
  /// **'Pilih bahasa aplikasi'**
  String get onboardingLanguageHeading;

  /// Tindakan melengkapkan onboarding.
  ///
  /// In ms, this message translates to:
  /// **'Teruskan'**
  String get continueLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ms'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ms':
      return AppLocalizationsMs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
