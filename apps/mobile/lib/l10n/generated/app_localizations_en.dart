// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sunnah Everyday';

  @override
  String get navigationSemantics => 'Primary navigation';

  @override
  String get navToday => 'Today';

  @override
  String get navExplore => 'Explore';

  @override
  String get navSaved => 'Saved';

  @override
  String get navSettings => 'Settings';

  @override
  String get todayHeading => 'Today';

  @override
  String get todayIntro => 'A calm space to learn one step at a time.';

  @override
  String get dailyCardEyebrow => 'Daily status';

  @override
  String get dailyCardStatusAction => 'View content status';

  @override
  String get dailyDetailTitle => 'Content status';

  @override
  String get dailyDetailUnavailableTitle => 'Details are not available yet';

  @override
  String get backToToday => 'Back to Today';

  @override
  String get contentStatusEyebrow => 'Content status';

  @override
  String get noApprovedContentTitle => 'No approved content yet';

  @override
  String get noApprovedContentMessage =>
      'Content will appear only after the required source records, usage rights and human reviews are available.';

  @override
  String get accuracyFirstTitle => 'Accuracy comes first';

  @override
  String get accuracyFirstMessage =>
      'The app does not show religious claims before they complete the recorded approval process.';

  @override
  String get exploreTitle => 'Explore';

  @override
  String get exploreEmptyTitle => 'No collections to explore yet';

  @override
  String get exploreEmptyMessage =>
      'Categories, situations and search will show approved content only.';

  @override
  String get savedTitle => 'Saved';

  @override
  String get savedEmptyTitle => 'Nothing saved yet';

  @override
  String get savedEmptyMessage =>
      'Saved content appears only after a verified public content reference is available. Private reflections stay on this device.';

  @override
  String get savedContentHeading => 'Saved content';

  @override
  String get savedContentUnavailableTitle => 'No verified content to save yet';

  @override
  String get savedContentUnavailableMessage =>
      'Bookmarks and view history become available only after a verified public bundle provides a real content reference.';

  @override
  String get privateReflectionsHeading => 'Private reflections';

  @override
  String get privateReflectionsDescription =>
      'These notes stay on this device and are not sent from the app.';

  @override
  String get privateReflectionInputLabel => 'New note';

  @override
  String get privateReflectionInputHint => 'Write for yourself';

  @override
  String get savePrivateReflection => 'Save note';

  @override
  String get privateReflectionsEmptyTitle => 'No private reflections yet';

  @override
  String get privateReflectionsEmptyMessage =>
      'Notes you save will appear on this device.';

  @override
  String get deletePrivateReflection => 'Delete note';

  @override
  String get privateReflectionStorageUnavailableTitle =>
      'Private reflections are unavailable';

  @override
  String get privateReflectionStorageUnavailableMessage =>
      'Private storage could not open safely on this device. No new data is saved.';

  @override
  String get privateReflectionSaveFailed =>
      'The note could not be saved. Try again.';

  @override
  String get privateReflectionDeleteFailed =>
      'The note could not be deleted. Try again.';

  @override
  String get privateReflectionsLimitReached =>
      'The private-reflection limit has been reached.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get displayHeading => 'Display';

  @override
  String get languageLabel => 'Language';

  @override
  String get malayLanguage => 'Bahasa Melayu';

  @override
  String get englishLanguage => 'English';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get reduceMotionTitle => 'Reduce motion';

  @override
  String get reduceMotionSubtitle => 'Limit non-essential movement.';

  @override
  String get textSizeTitle => 'Text size';

  @override
  String textScalePercent(int percent) {
    return '$percent%';
  }

  @override
  String get textSizePreview => 'A comfortable text preview.';

  @override
  String get privacyHeading => 'Privacy';

  @override
  String get privacyMessage =>
      'A user account is not required. Private reflections stay on this device and are not sent to a server.';

  @override
  String get privateDataHeading => 'Private reflections';

  @override
  String get privateDataMessage =>
      'Private reflections stay on this device and are not sent to a server. You can delete all saved private reflections.';

  @override
  String get deleteAllPrivateData => 'Delete all private reflections';

  @override
  String get deleteAllPrivateDataTitle => 'Delete all private reflections?';

  @override
  String get deleteAllPrivateDataMessage =>
      'This removes every private reflection saved on this device. It cannot be undone in the app.';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get privateDataDeleted => 'Private reflections deleted.';

  @override
  String get privateDataDeleteFailed =>
      'Private reflections could not be deleted. Try again.';

  @override
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingDescription =>
      'Choose the app language before continuing. Content appears only after the required review and approval.';

  @override
  String get onboardingLanguageHeading => 'Choose the app language';

  @override
  String get continueLabel => 'Continue';
}
